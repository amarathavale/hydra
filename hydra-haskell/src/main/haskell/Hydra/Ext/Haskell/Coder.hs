module Hydra.Ext.Haskell.Coder (
  dataGraphToHaskellModule,
  haskellLanguage,
) where

import Hydra.Adapter
import Hydra.Adapters.Term
import Hydra.Basics
import Hydra.Core
import Hydra.CoreDecoding
import Hydra.CoreLanguage
import Hydra.Evaluation
import Hydra.Graph
import Hydra.Impl.Haskell.Dsl.CoreMeta
import Hydra.Impl.Haskell.Extras
import Hydra.Primitives
import Hydra.Rewriting
import Hydra.Util.Coders
import Hydra.Util.Formatting
import qualified Hydra.Ext.Haskell.Ast as H
import qualified Hydra.Lib.Strings as Strings
import qualified Hydra.Impl.Haskell.Dsl.Types as Types

import qualified Control.Monad as CM
import qualified Data.List as L
import qualified Data.Map as M
import qualified Data.Set as S
import qualified Data.Maybe as Y


constantDecls :: Name -> Type m -> [H.DeclarationWithComments]
constantDecls name typ = toDecl <$> (nameDecl:fieldDecls)
  where
    lname = localNameOf name
    toDecl (k, v) = H.DeclarationWithComments decl Nothing
      where
        decl = H.DeclarationValueBinding $
          H.ValueBindingSimple $ H.ValueBinding_Simple pat rhs Nothing
        pat = H.PatternApplication $ H.Pattern_Application (simpleName k) []
        rhs = H.ExpressionLiteral $ H.LiteralString v
    nameDecl = ("_" ++ lname, name)
    fieldsOf typ = case typeData typ of
      TypeExprRecord fields -> fields
      TypeExprUnion fields -> fields
      _ -> []
    fieldDecls = toConstant <$> (fieldsOf $ snd $ unpackUniversalType typ)
    toConstant (FieldType fname _) = ("_" ++ lname ++ "_" ++ fname, fname)

constructModule :: (Default m, Ord m, Read m, Show m)
  => Context m -> Graph m -> M.Map (Type m) (Step (Term m) H.Expression) -> [(Element m, TypedTerm m)] -> Result H.Module
constructModule cx g coders pairs = do
    decls <- L.concat <$> (CM.mapM createDeclarations pairs)
    return $ H.Module (Just $ H.ModuleHead (importName $ graphName g) []) imports decls
  where
    createDeclarations pair@(el, TypedTerm typ term) = if typeData typ == TypeExprNominal _Type
      then createTypeDeclarations el term
      else createOtherDeclarations pair

    createTypeDeclarations el term = do
        let lname = localNameOf $ elementName el
        let hname = simpleName lname
        t <- decodeType cx term
        isSer <- isSerializable t
        let deriv = if isSer
                      then simpleName <$> ["Eq", "Ord", "Read", "Show"]
                      else []
        let (vars, t') = unpackUniversalType t
        let hd = declHead hname $ L.reverse vars
        decl <- case typeData t' of
          TypeExprRecord fields -> do
            cons <- recordCons lname fields
            return $ H.DeclarationData (H.DataDeclaration H.DataDeclaration_KeywordData [] hd [cons] [deriv])
          TypeExprUnion fields -> do
            cons <- CM.mapM (unionCons lname) fields
            return $ H.DeclarationData (H.DataDeclaration H.DataDeclaration_KeywordData [] hd cons [deriv])
          _ -> do
            htype <- encodeAdaptedType importAliases cx t
            return $ H.DeclarationType (H.TypeDeclaration hd htype)
        let comments = contextDescriptionOf cx $ termMeta term
        return $ [H.DeclarationWithComments decl comments] ++ constantDecls (elementName el) t
      where
        isSerializable typ = do
            deps <- typeDependencies cx (elementName el)
            let allVariants = S.fromList $ L.concat (variants <$> M.elems deps)
            return $ not $ S.member TypeVariantFunction allVariants
          where
            variants typ = typeVariant <$> (foldOverType TraversalOrderPre (\m t -> t:m) [] typ)

        declHead name vars = case vars of
          [] -> H.DeclarationHeadSimple name
          (h:rest) -> H.DeclarationHeadApplication $ H.DeclarationHead_Application (declHead name rest) (simpleName h)

        recordCons lname fields = do
            hFields <- CM.mapM toField fields
            return $ H.ConstructorRecord $ H.Constructor_Record (simpleName lname) hFields
          where
            toField (FieldType fname ftype) = do
              let hname = simpleName $ decapitalize lname ++ capitalize fname
              htype <- encodeAdaptedType importAliases cx ftype
              return $ H.Field hname htype

        unionCons lname (FieldType fname ftype) = do
          let nm = capitalize lname ++ capitalize fname
          typeList <- if ftype == Types.unit
            then pure []
            else do
              htype <- encodeAdaptedType importAliases cx ftype
              return [htype]
          return $ H.ConstructorOrdinary $ H.Constructor_Ordinary (simpleName nm) typeList

    createOtherDeclarations (el, TypedTerm typ term) = do
      let coder = Y.fromJust $ M.lookup typ coders
      rhs <- stepOut coder term
      let hname = simpleName $ localNameOf $ elementName el
      let pat = H.PatternApplication $ H.Pattern_Application hname []
      htype <- encodeType importAliases typ
      let decl = H.DeclarationTypedBinding $ H.TypedBinding
                  (H.TypeSignature hname htype)
                  (H.ValueBindingSimple $ rewriteValueBinding $ H.ValueBinding_Simple pat rhs Nothing)
      let comments = contextDescriptionOf cx $ termMeta term
      return [H.DeclarationWithComments decl comments]

    toCons _ = H.Constructor_Record

    importAliases = importAliasesForGraph g
    importName name = L.intercalate "." (capitalize <$> Strings.splitOn "/" name)
    imports = domainImports ++ standardImports
      where
        domainImports = toImport <$> M.toList importAliases
          where
            toImport (name, alias) = H.Import True (importName name) (Just alias) Nothing
        standardImports = toImport <$> ["Data.Map", "Data.Set"]
          where
            toImport name = H.Import False name Nothing Nothing

    rewriteValueBinding vb = case vb of
      H.ValueBinding_Simple (H.PatternApplication (H.Pattern_Application name args)) rhs bindings -> case rhs of
        H.ExpressionLambda (H.Expression_Lambda vars body) -> rewriteValueBinding $
          H.ValueBinding_Simple
            (H.PatternApplication (H.Pattern_Application name (args ++ vars))) body bindings
        _ -> vb

dataGraphToHaskellModule :: (Default m, Ord m, Read m, Show m) => Context m -> Graph m -> Qualified H.Module
dataGraphToHaskellModule cx g = dataGraphToExternalModule haskellLanguage (encodeTerm aliases) constructModule cx g
  where
    aliases = importAliasesForGraph g

elementReference :: M.Map Name String -> Name -> H.Name
elementReference aliases name = case alias of
    Nothing -> simpleName local
    Just a -> rawName $ a ++ "." ++ sanitize local
  where
    (ns, local) = toQname name
    alias = M.lookup ns aliases

encodeAdaptedType :: (Default m, Ord m, Read m, Show m) => M.Map Name String -> Context m -> Type m -> Result H.Type
encodeAdaptedType aliases cx typ = do
  let ac = AdapterContext cx hydraCoreLanguage haskellLanguage
  ad <- qualifiedToResult $ termAdapter ac typ
  encodeType aliases $ adapterTarget ad

encodeFunction :: (Default m, Eq m, Ord m, Read m, Show m) => M.Map Name String -> Context m -> m -> Function m -> Result H.Expression
encodeFunction aliases cx meta fun = case fun of
    FunctionCases fields -> hslambda "x" <$> caseExpr -- note: could use a lambda case here
      where
        caseExpr = do
          fieldMap <- fieldMapOf <$> findDomain
          H.ExpressionCase <$> (H.Expression_Case (hsvar "x") <$> CM.mapM (toAlt fieldMap) fields)
        toAlt fieldMap (Field fn fun') = do
          let v0 = "v"
          let rhsTerm = simplifyTerm $ apply fun' (variable v0)
          let v1 = if isFreeIn v0 rhsTerm then "_" else v0
          hname <- case domName of
            Just n -> pure $ unionFieldReference aliases n fn
            Nothing -> fail $ "unqualified field name"
          args <- case fieldMap >>= M.lookup fn of
                Just (FieldType _ (Type (TypeExprRecord []) _)) -> pure []
                Just _ -> pure [H.PatternName $ rawName v1]
                Nothing -> fail $ "field " ++ show fn ++ " not found in " ++ show domName
          let lhs = H.PatternApplication $ H.Pattern_Application hname args
          rhs <- encodeTerm aliases cx rhsTerm
          return $ H.Alternative lhs rhs Nothing
    FunctionData -> pure $ hsvar "id"
    FunctionLambda (Lambda v body) -> hslambda v <$> encodeTerm aliases cx body
    FunctionOptionalCases (OptionalCases nothing just) -> do
      nothingRhs <- encodeTerm aliases cx nothing
      let nothingAlt = H.Alternative (H.PatternName $ simpleName "Nothing") nothingRhs Nothing
      justAlt <- do
        -- Note: some of the following could be brought together with FunctionCases
        let v0 = "v"
        let rhsTerm = simplifyTerm $ apply just (variable v0)
        let v1 = if S.member v0 $ freeVariablesInTerm rhsTerm then v0 else "_"
        let lhs = H.PatternApplication $ H.Pattern_Application (rawName "Just") [H.PatternName $ rawName v1]
        rhs <- encodeTerm aliases cx rhsTerm
        return $ H.Alternative lhs rhs Nothing
      return $ H.ExpressionCase $ H.Expression_Case (hsvar "x") [nothingAlt, justAlt]
    FunctionPrimitive name -> pure $ H.ExpressionVariable $ hsPrimitiveReference name
    FunctionProjection fname -> case domName of
      Just n -> pure $ H.ExpressionVariable $ recordFieldReference aliases n fname
      Nothing -> fail $ "unqualified record"
    _ -> fail $ "unexpected function: " ++ show fun
  where
    fieldMapOf typ = case typeData <$> typ of
      Just (TypeExprUnion tfields) -> Just $ M.fromList $ (\f -> (fieldTypeName f, f)) <$> tfields
      Just (TypeExprUniversal (UniversalType _ tbody)) -> fieldMapOf $ Just tbody
      _ -> Nothing
    findDomain = case domName of
      Nothing -> pure Nothing
      Just name -> do
        scx <- schemaContext cx -- TODO: cache this
        typ <- requireType scx name
        return $ Just typ
    domName = case contextTypeOf cx meta of
        Just typ -> case typeData typ of
          TypeExprFunction (FunctionType dom _) -> nomName dom
          _ -> Nothing
        Nothing -> Nothing
      where
        nomName typ = case typeData typ of
          TypeExprNominal name -> Just name
          TypeExprUniversal (UniversalType _ body) -> nomName body
          _ -> Nothing

encodeLiteral :: Literal -> Result H.Expression
encodeLiteral av = case av of
    LiteralBoolean b -> pure $ hsvar $ case b of
      BooleanValueTrue -> "True"
      _ -> "False"
    LiteralFloat fv -> case fv of
      FloatValueFloat32 f -> pure $ hslit $ H.LiteralFloat f
      FloatValueFloat64 f -> pure $ hslit $ H.LiteralDouble f
      _ -> unexpected "floating-point number" fv
    LiteralInteger iv -> case iv of
      IntegerValueBigint i -> pure $ hslit $ H.LiteralInteger i
      IntegerValueInt32 i -> pure $ hslit $ H.LiteralInt i
      _ -> unexpected "integer" iv
    LiteralString s -> pure $ hslit $ H.LiteralString s
    _ -> unexpected "literal value" av

encodeTerm :: (Default m, Eq m, Ord m, Read m, Show m) => M.Map Name String -> Context m -> Term m -> Result H.Expression
encodeTerm aliases cx term@(Term expr meta) = do
   case expr of
    ExpressionApplication (Application fun arg) -> case termData fun of
       ExpressionFunction FunctionData -> encode cx arg
       _ -> hsapp <$> encode cx fun <*> encode cx arg
    ExpressionElement name -> pure $ H.ExpressionVariable $ elementReference aliases name
    ExpressionFunction f -> encodeFunction aliases cx (termMeta term) f
    ExpressionList els -> H.ExpressionList <$> CM.mapM (encode cx) els
    ExpressionLiteral v -> encodeLiteral v
    ExpressionNominal (NominalTerm _ term') -> encode cx term'
    ExpressionOptional m -> case m of
      Nothing -> pure $ hsvar "Nothing"
      Just t -> hsapp (hsvar "Just") <$> encode cx t
    ExpressionRecord fields -> case sname of
      Nothing -> case fields of
          [] -> pure $ H.ExpressionTuple []
          _ -> fail $ "unexpected anonymous record: " ++ show term
      Just name -> do
          let typeName = typeNameForRecord name
          updates <- CM.mapM toFieldUpdate fields
          return $ H.ExpressionConstructRecord $ H.Expression_ConstructRecord (rawName typeName) updates
        where
          toFieldUpdate (Field fn ft) = H.FieldUpdate (recordFieldReference aliases name fn) <$> encode cx ft
    ExpressionUnion (Field fn ft) -> do
      lhs <- case sname of
        Just n -> pure $ H.ExpressionVariable $ unionFieldReference aliases n fn
        Nothing -> fail $ "unqualified field"
      case termData ft of
        ExpressionRecord [] -> pure lhs
        _ -> hsapp lhs <$> encode cx ft
    ExpressionVariable v -> pure $ hsvar v
    _ -> fail $ "unexpected term: " ++ show term
  where
    encode = encodeTerm aliases
    sname = case typeData <$> (contextTypeOf cx meta) of
      Just (TypeExprNominal name) -> Just name
      Nothing -> Nothing

encodeType :: Show m => M.Map Name String -> Type m -> Result H.Type
encodeType aliases typ = case typeData typ of
    TypeExprElement et -> encode et
    TypeExprFunction (FunctionType dom cod) -> H.TypeFunction <$> (H.Type_Function <$> encode dom <*> encode cod)
    TypeExprList lt -> H.TypeList <$> encode lt
    TypeExprLiteral lt -> H.TypeVariable . simpleName <$> case lt of
      LiteralTypeBoolean -> pure "Bool"
      LiteralTypeFloat ft -> case ft of
        FloatTypeFloat32 -> pure "Float"
        FloatTypeFloat64 -> pure "Double"
        _ -> fail $ "unexpected floating-point type: " ++ show ft
      LiteralTypeInteger it -> case it of
        IntegerTypeBigint -> pure "Integer"
        IntegerTypeInt32 -> pure "Int"
        _ -> fail $ "unexpected integer type: " ++ show it
      LiteralTypeString -> pure "String"
      _ -> fail $ "unexpected literal type: " ++ show lt
    TypeExprMap (MapType kt vt) -> toApplicationType <$> CM.sequence [
      pure $ H.TypeVariable $ simpleName "Map",
      encode kt,
      encode vt]
    TypeExprNominal name -> pure $ H.TypeVariable $ elementReference aliases name
    TypeExprOptional ot -> toApplicationType <$> CM.sequence [
      pure $ H.TypeVariable $ simpleName "Maybe",
      encode ot]
    TypeExprSet st -> toApplicationType <$> CM.sequence [
      pure $ H.TypeVariable $ simpleName "Set",
      encode st]
    TypeExprUniversal (UniversalType v body) -> toApplicationType <$> CM.sequence [
      encode body,
      pure $ H.TypeVariable $ simpleName v]
    TypeExprVariable v -> pure $ H.TypeVariable $ simpleName v
    TypeExprRecord [] -> pure $ H.TypeTuple []
    _ -> fail $ "unexpected type: " ++ show typ
  where
    encode = encodeType aliases

haskellLanguage :: Language m
haskellLanguage = Language "hydra/ext/haskell" $ Language_Constraints {
  languageConstraintsLiteralVariants = S.fromList [
    LiteralVariantBoolean, LiteralVariantFloat, LiteralVariantInteger, LiteralVariantString],
  languageConstraintsFloatTypes = S.fromList [
    -- Bigfloat is excluded for now
    FloatTypeFloat32,
    FloatTypeFloat64],
  languageConstraintsFunctionVariants = S.fromList functionVariants,
  languageConstraintsIntegerTypes = S.fromList [IntegerTypeBigint, IntegerTypeInt32],
  languageConstraintsTermVariants = S.fromList [
    TermVariantApplication,
    TermVariantElement,
    TermVariantFunction,
    TermVariantList,
    TermVariantLiteral,
    TermVariantMap,
    TermVariantNominal,
    TermVariantOptional,
    TermVariantRecord,
    TermVariantSet,
    TermVariantUnion,
    TermVariantVariable],
  languageConstraintsTypeVariants = S.fromList [
    TypeVariantElement,
    TypeVariantFunction,
    TypeVariantList,
    TypeVariantLiteral,
    TypeVariantMap,
    TypeVariantNominal,
    TypeVariantOptional,
    TypeVariantRecord,
    TypeVariantSet,
    TypeVariantUnion,
    TypeVariantUniversal,
    TypeVariantVariable],
  languageConstraintsTypes = const True }

hsapp :: H.Expression -> H.Expression -> H.Expression
hsapp l r = H.ExpressionApplication $ H.Expression_Application l r

hslambda :: H.NamePart -> H.Expression -> H.Expression
hslambda v rhs = H.ExpressionLambda (H.Expression_Lambda [H.PatternName $ rawName v] rhs)

hslit :: H.Literal -> H.Expression
hslit = H.ExpressionLiteral

hsPrimitiveReference :: Name -> H.Name
hsPrimitiveReference name = H.NameNormal $ H.QualifiedName [prefix] local
  where
    (ns, local) = toQname name
    prefix = capitalize $ L.last $ Strings.splitOn "/" ns

hsvar :: H.NamePart -> H.Expression
hsvar = H.ExpressionVariable . rawName

importAliasesForGraph :: Show m => Graph m -> M.Map Name String
importAliasesForGraph g = fst $ L.foldl addPair (M.empty, S.empty) (toPair <$> (S.toList $ dataGraphDependencies True True True g))
  where
    toPair name = (name, capitalize $ L.last $ Strings.splitOn "/" name)
    addPair (m, s) (name, alias) = if S.member alias s
      then addPair (m, s) (name, alias ++ "_")
      else (M.insert name alias m, S.insert alias s)

rawName :: String -> H.Name
rawName n = H.NameNormal $ H.QualifiedName [] n

recordFieldReference :: M.Map Name String -> Name -> FieldName -> H.Name
recordFieldReference aliases sname fname = elementReference aliases $ fromQname (fst $ toQname sname) nm
  where
    nm = decapitalize (typeNameForRecord sname) ++ capitalize fname

sanitize :: Name -> String
sanitize = fmap (\c -> if c == '.' then '_' else c)

simpleName :: Name -> H.Name
simpleName = rawName . sanitize

toApplicationType :: [H.Type] -> H.Type
toApplicationType = app . L.reverse
  where
    app l = case l of
      [e] -> e
      (h:r) -> H.TypeApplication $ H.Type_Application (app r) h

typeNameForRecord :: Name -> String
typeNameForRecord sname = L.last (Strings.splitOn "." sname)

unionFieldReference :: M.Map Name String -> Name -> FieldName -> H.Name
unionFieldReference aliases sname fname = elementReference aliases $ fromQname (fst $ toQname sname) nm
  where
    nm = capitalize (typeNameForRecord sname) ++ capitalize fname

unpackUniversalType :: Type m -> ([TypeVariable], Type m)
unpackUniversalType t = case typeData t of
  TypeExprUniversal (UniversalType v tbody) -> (v:vars, t')
    where
      (vars, t') = unpackUniversalType tbody
  _ -> ([], t)
