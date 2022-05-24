module Hydra.Ext.Pegasus.Coder (
  dataGraphToPegasusSchema,
  pegasusDataLanguage,
) where

import Hydra.Adapter
import Hydra.Adapters.Term
import Hydra.Core
import Hydra.CoreDecoding
import Hydra.CoreLanguage
import Hydra.Evaluation
import Hydra.Graph
import Hydra.Impl.Haskell.Extras
import Hydra.Rewriting
import Hydra.Util.Coders
import Hydra.Util.Formatting
import qualified Hydra.Ext.Pegasus.Pdl as PDL
import qualified Hydra.Impl.Haskell.Dsl.Types as Types

import qualified Control.Monad as CM
import qualified Data.List as L
import qualified Data.Map as M
import qualified Data.Set as S
import qualified Data.Maybe as Y


constructModule :: (Default m, Ord m, Read m, Show m)
  => Context m -> Graph m -> M.Map (Type m) (Step (Data m) ()) -> [(Element m, TypedData m)] -> Result PDL.SchemaFile
constructModule cx g coders pairs = do
    let ns = pdlNameForGraph g
    let pkg = Nothing
    let imports = [] -- TODO
    sortedPairs <- case (topologicalSortElements $ fst <$> pairs) of
      Nothing -> fail $ "types form a cycle (unsupported in PDL)"
      Just sorted -> pure $ Y.catMaybes $ fmap (\n -> M.lookup n pairByName) sorted
    schemas <- CM.mapM toSchema sortedPairs
    return $ PDL.SchemaFile ns pkg imports schemas
  where
    pairByName = L.foldl (\m p@(el, tt) -> M.insert (elementName el) p m) M.empty pairs
    aliases = importAliasesForGraph g
    toSchema (el, TypedData typ term) = if typeTerm typ == TypeTermNominal _Type
      then decodeType cx term >>= typeToSchema el
      else fail $ "mapping of non-type elements to PDL is not yet supported: " ++ show typ
    typeToSchema el typ = do
      let qname = pdlNameForElement aliases False $ elementName el
      res <- encodeAdaptedType aliases cx typ
      let ptype = case res of
            Left schema -> PDL.NamedSchema_TypeTyperef schema
            Right t -> t
      r <- contextDescriptionOf cx $ dataMeta $ elementData el
      let anns = doc r
      return $ PDL.NamedSchema qname ptype anns

dataGraphToPegasusSchema :: (Default m, Ord m, Read m, Show m) => Context m -> Graph m -> Qualified PDL.SchemaFile
dataGraphToPegasusSchema cx g = dataGraphToExternalModule pegasusDataLanguage (encodeData aliases) constructModule cx g
  where
    aliases = importAliasesForGraph g

doc :: Y.Maybe String -> PDL.Annotations
doc s = PDL.Annotations s False

encodeAdaptedType :: (Default m, Ord m, Read m, Show m)
  => M.Map GraphName String -> Context m -> Type m
  -> Result (Either PDL.Schema PDL.NamedSchema_Type)
encodeAdaptedType aliases cx typ = do
  let ac = AdapterContext cx hydraCoreLanguage pegasusDataLanguage
  ad <- qualifiedToResult $ termAdapter ac typ
  encodeType aliases cx $ adapterTarget ad

encodeData :: (Default m, Eq m, Ord m, Read m, Show m) => M.Map GraphName String -> Context m -> Data m -> Result ()
encodeData aliases cx term@(Data expr meta) = do
    fail "not yet implemented"

encodeType :: (Default m, Eq m, Show m) => M.Map GraphName String -> Context m -> Type m -> Result (Either PDL.Schema PDL.NamedSchema_Type)
encodeType aliases cx typ = case typeTerm typ of
    TypeTermList lt -> Left . PDL.SchemaArray <$> encode lt
    TypeTermLiteral lt -> Left . PDL.SchemaPrimitive <$> case lt of
      LiteralTypeBinary -> pure PDL.PrimitiveTypeBytes
      LiteralTypeBoolean -> pure PDL.PrimitiveTypeBoolean
      LiteralTypeFloat ft -> case ft of
        FloatTypeFloat32 -> pure PDL.PrimitiveTypeFloat
        FloatTypeFloat64 -> pure PDL.PrimitiveTypeDouble
        _ -> fail $ "unexpected floating-point type: " ++ show ft
      LiteralTypeInteger it -> case it of
        IntegerTypeInt32 -> pure PDL.PrimitiveTypeInt
        IntegerTypeInt64 -> pure PDL.PrimitiveTypeLong
        _ -> fail $ "unexpected integer type: " ++ show it
      LiteralTypeString -> pure PDL.PrimitiveTypeString
    TypeTermMap (MapType kt vt) -> Left . PDL.SchemaMap <$> encode vt -- note: we simply assume string as a key type
    TypeTermNominal name -> pure $ Left $ PDL.SchemaNamed $ pdlNameForElement aliases True name
    TypeTermOptional ot -> fail $ "optionals unexpected at top level"
    TypeTermRecord fields -> do
      let includes = []
      rfields <- CM.mapM encodeRecordField fields
      return $ Right $ PDL.NamedSchema_TypeRecord $ PDL.RecordSchema rfields includes
    TypeTermUnion fields -> if isEnum
        then do
          fs <- CM.mapM encodeEnumField fields
          return $ Right $ PDL.NamedSchema_TypeEnum $ PDL.EnumSchema fs
        else Left . PDL.SchemaUnion . PDL.UnionSchema <$> CM.mapM encodeUnionField fields
      where
        isEnum = L.foldl (\b t -> b && t {typeMeta = dflt} == Types.unit) True $ fmap fieldTypeType fields
    _ -> fail $ "unexpected type: " ++ show typ
  where
    encode t = case typeTerm t of
      TypeTermRecord [] -> encode Types.int32 -- special case for the unit type
      _ -> do
        res <- encodeType aliases cx t
        case res of
          Left schema -> pure schema
          Right _ -> fail $ "type resolved to an unsupported nested named schema: " ++ show t
    encodeRecordField (FieldType (FieldName name) typ) = do
      anns <- getAnns typ
      (schema, optional) <- encodePossiblyOptionalType typ
      return PDL.RecordField {
        PDL.recordFieldName = PDL.FieldName name,
        PDL.recordFieldValue = schema,
        PDL.recordFieldOptional = optional,
        PDL.recordFieldDefault = Nothing,
        PDL.recordFieldAnnotations = anns}
    encodeUnionField (FieldType (FieldName name) typ) = do
      anns <- getAnns typ
      (s, optional) <- encodePossiblyOptionalType typ
      let schema = if optional
          then PDL.SchemaUnion $ PDL.UnionSchema (simpleUnionMember <$> [PDL.SchemaNull, s])
          else s
      return PDL.UnionMember {
        PDL.unionMemberAlias = Just $ PDL.FieldName name,
        PDL.unionMemberValue = schema,
        PDL.unionMemberAnnotations = anns}
    encodeEnumField (FieldType (FieldName name) typ) = do
      anns <- getAnns typ
      return PDL.EnumField {
        PDL.enumFieldName = PDL.EnumFieldName $ convertCase CaseCamel CaseUpperSnake name,
        PDL.enumFieldAnnotations = anns}
    encodePossiblyOptionalType typ = case typeTerm typ of
      TypeTermOptional ot -> do
        t <- encode ot
        return (t, True)
      _ -> do
        t <- encode typ
        return (t, False)
    getAnns typ = do
      r <- contextDescriptionOf cx $ typeMeta typ
      return $ doc r

importAliasesForGraph g = M.empty -- TODO

noAnnotations = PDL.Annotations Nothing False

pdlNameForElement :: M.Map GraphName String -> Bool -> Name -> PDL.QualifiedName
pdlNameForElement aliases withNs name = PDL.QualifiedName (PDL.Name local)
    $ if withNs
      then PDL.Namespace . slashesToDots <$> alias
      else Nothing
  where
    (ns, local) = toQname name
    alias = M.lookup ns aliases

pdlNameForGraph :: Graph m -> PDL.Namespace
pdlNameForGraph = PDL.Namespace . slashesToDots . h . graphName
  where
    h (GraphName n) = n
      
pegasusDataLanguage :: Language m
pegasusDataLanguage = Language (LanguageName "hydra/ext/pegasus/pdl") $ LanguageConstraints {
  languageConstraintsLiteralVariants = S.fromList [
    LiteralVariantBinary,
    LiteralVariantBoolean,
    LiteralVariantFloat,
    LiteralVariantInteger,
    LiteralVariantString],
  languageConstraintsFloatTypes = S.fromList [
    FloatTypeFloat32,
    FloatTypeFloat64],
  languageConstraintsFunctionVariants = S.empty,
  languageConstraintsIntegerTypes = S.fromList [
    IntegerTypeInt32,
    IntegerTypeInt64],
  languageConstraintsDataVariants = S.fromList [
    DataVariantList,
    DataVariantLiteral,
    DataVariantMap,
    DataVariantNominal,
    DataVariantOptional,
    DataVariantRecord,
    DataVariantUnion],
  languageConstraintsTypeVariants = S.fromList [
    TypeVariantElement,
    TypeVariantList,
    TypeVariantLiteral,
    TypeVariantMap,
    TypeVariantNominal,
    TypeVariantOptional,
    TypeVariantRecord,
    TypeVariantUnion],
  languageConstraintsTypes = const True }

simpleUnionMember :: PDL.Schema -> PDL.UnionMember
simpleUnionMember schema = PDL.UnionMember Nothing schema noAnnotations

slashesToDots :: String -> String
slashesToDots = fmap (\c -> if c == '/' then '.' else c)