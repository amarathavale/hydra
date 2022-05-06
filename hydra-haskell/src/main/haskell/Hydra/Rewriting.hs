module Hydra.Rewriting (
  TraversalOrder(..),
  foldOverTerm,
  foldOverType,
  freeVariablesInTerm,
  isFreeIn,
  rewriteTerm,
  rewriteTermMeta,
  rewriteType,
  rewriteTypeMeta,
  simplifyTerm,
  stripMeta,
  substituteVariable,
  subterms,
  subtypes,
  termDependencyNames,
  topologicalSortElements,
  typeDependencyNames,
  typeDependencies,
  ) where

import Hydra.Core
import Hydra.Impl.Haskell.Extras
import Hydra.Impl.Haskell.Dsl.CoreMeta
import Hydra.Graph
import Hydra.Primitives
import Hydra.Evaluation
import Hydra.CoreDecoding
import Hydra.Sorting

import qualified Control.Monad as CM
import qualified Data.List as L
import qualified Data.Map as M
import qualified Data.Set as S
import qualified Data.Maybe as Y

data TraversalOrder = TraversalOrderPre | TraversalOrderPost

foldOverTerm :: TraversalOrder -> (a -> Term m -> a) -> a -> Term m -> a
foldOverTerm order fld b0 term = case order of
    TraversalOrderPre -> L.foldl (foldOverTerm order fld) (fld b0 term) children
    TraversalOrderPost -> fld (L.foldl (foldOverTerm order fld) b0 children) term
  where
    children = subterms term

foldOverType :: TraversalOrder -> (a -> Type m -> a) -> a -> Type m -> a
foldOverType order fld b0 typ = case order of
    TraversalOrderPre -> L.foldl (foldOverType order fld) (fld b0 typ) children
    TraversalOrderPost -> fld (L.foldl (foldOverType order fld) b0 children) typ
  where
    children = subtypes typ

freeVariablesInTerm :: Term m -> S.Set Variable
freeVariablesInTerm term = case termData term of
  ExpressionFunction (FunctionLambda (Lambda var body)) -> S.delete var $ freeVariablesInTerm body
  ExpressionVariable v -> S.fromList [v]
  _ -> L.foldl (\s t -> S.union s $ freeVariablesInTerm t) S.empty $ subterms term

isFreeIn :: Variable -> Term m -> Bool
isFreeIn v term = not $ S.member v $ freeVariablesInTerm term

rewriteTerm :: (Ord a, Ord b) => ((Term a -> Term b) -> Term a -> Term b) -> (a -> b) -> Term a -> Term b
rewriteTerm mapData mapMeta = replace
  where
    replace = mapData recurse
    replaceField f = f {fieldTerm = replace (fieldTerm f)}
    recurse (Term expr meta) = Term expr1 $ mapMeta meta
      where
        expr1 = case expr of
          ExpressionApplication (Application lhs rhs) -> ExpressionApplication $ Application (replace lhs) (replace rhs)
          ExpressionElement name -> ExpressionElement name
          ExpressionFunction fun -> ExpressionFunction $ case fun of
            FunctionCases fields -> FunctionCases $ replaceField <$> fields
            FunctionCompareTo other -> FunctionCompareTo $ replace other
            FunctionData -> FunctionData
            FunctionLambda (Lambda v body) -> FunctionLambda $ Lambda v $ replace body
            FunctionOptionalCases (OptionalCases nothing just) -> FunctionOptionalCases
              (OptionalCases (replace nothing) (replace just))
            FunctionPrimitive name -> FunctionPrimitive name
            FunctionProjection fname -> FunctionProjection fname
          ExpressionLet (Let v t1 t2) -> ExpressionLet $ Let v (replace t1) (replace t2)
          ExpressionList els -> ExpressionList $ replace <$> els
          ExpressionLiteral v -> ExpressionLiteral v
          ExpressionMap m -> ExpressionMap $ M.fromList $ (\(k, v) -> (replace k, replace v)) <$> M.toList m
          ExpressionNominal (NominalTerm name t) -> ExpressionNominal (NominalTerm name $ replace t)
          ExpressionOptional m -> ExpressionOptional $ replace <$> m
          ExpressionRecord fields -> ExpressionRecord $ replaceField <$> fields
          ExpressionSet s -> ExpressionSet $ S.fromList $ replace <$> S.toList s
          ExpressionTypeAbstraction (TypeAbstraction v b0) -> ExpressionTypeAbstraction $ TypeAbstraction v (replace b0)
          ExpressionTypeApplication (TypeApplication f t) -> ExpressionTypeApplication $ TypeApplication (replace f) $
            rewriteTypeMeta mapMeta t
          ExpressionUnion field -> ExpressionUnion $ replaceField field
          ExpressionVariable v -> ExpressionVariable v

rewriteTermMeta :: (Ord a, Ord b) => (a -> b) -> Term a -> Term b
rewriteTermMeta mapMeta = rewriteTerm mapData mapMeta
  where
    mapData recurse term = recurse term

rewriteType :: (Ord a, Ord b) => ((Type a -> Type b) -> Type a -> Type b) -> (a -> b) -> Type a -> Type b
rewriteType mapData mapMeta = replace
  where
    replace = mapData recurse
    replaceField f = f {fieldTypeType = replace (fieldTypeType f)}
    recurse (Type expr meta) = Type expr1 $ mapMeta meta
      where
        expr1 = case expr of
          TypeExprElement t -> TypeExprElement $ replace t
          TypeExprFunction (FunctionType dom cod) -> TypeExprFunction (FunctionType (replace dom) (replace cod))
          TypeExprList t -> TypeExprList $ replace t
          TypeExprLiteral lt -> TypeExprLiteral lt
          TypeExprMap (MapType kt vt) -> TypeExprMap (MapType (replace kt) (replace vt))
          TypeExprNominal name -> TypeExprNominal name
          TypeExprOptional t -> TypeExprOptional $ replace t
          TypeExprRecord fields -> TypeExprRecord $ replaceField <$> fields
          TypeExprSet t -> TypeExprSet $ replace t
          TypeExprUnion fields -> TypeExprUnion $ replaceField <$> fields
          TypeExprUniversal (UniversalType v b) -> TypeExprUniversal (UniversalType v $ replace b)
          TypeExprVariable v -> TypeExprVariable v

rewriteTypeMeta :: (Ord a, Ord b) => (a -> b) -> Type a -> Type b
rewriteTypeMeta mapMeta = rewriteType mapData mapMeta
  where
    mapData recurse term = recurse term

simplifyTerm :: (Default m, Ord m) => Term m -> Term m
simplifyTerm = rewriteTerm simplify id
  where
    simplify recurse term = recurse $ case termData term of
      ExpressionApplication (Application lhs rhs) -> case termData lhs of
        ExpressionFunction (FunctionLambda (Lambda var body)) -> if S.member var (freeVariablesInTerm body)
          then case termData rhs of
            ExpressionVariable v -> substituteVariable var v body
            _ -> term
          else body
        _ -> term
      _ -> term

stripMeta :: (Default m, Ord m) => Term m -> Term m
stripMeta = rewriteTermMeta $ \_ -> dflt

substituteVariable :: (Default m, Ord m) => Variable -> Variable -> Term m -> Term m
substituteVariable from to = rewriteTerm replace id
  where
    replace recurse term = case termData term of
      ExpressionVariable x -> recurse $ Term (ExpressionVariable $ if x == from then to else x) $ termMeta term
      ExpressionFunction (FunctionLambda (Lambda var _)) -> if var == from
        then term
        else recurse term
      _ -> recurse term

subterms :: Term m -> [Term m]
subterms term = case termData term of
  ExpressionApplication (Application lhs rhs) -> [lhs, rhs]
  ExpressionFunction f -> case f of
    FunctionCases cases -> fieldTerm <$> cases
    FunctionCompareTo other -> [other]
    FunctionLambda (Lambda _ body) -> [body]
    FunctionOptionalCases (OptionalCases nothing just) -> [nothing, just]
    _ -> []
  ExpressionLet (Let _ t1 t2) -> [t1, t2]
  ExpressionList els -> els
  ExpressionMap m -> L.concat ((\(k, v) -> [k, v]) <$> M.toList m)
  ExpressionNominal (NominalTerm _ t) -> [t]
  ExpressionOptional m -> Y.maybeToList m
  ExpressionRecord fields -> fieldTerm <$> fields
  ExpressionSet s -> S.toList s
  ExpressionUnion field -> [fieldTerm field]
  _ -> []

subtypes :: Type m -> [Type m]
subtypes typ = case typeData typ of
  TypeExprElement et -> [et]
  TypeExprFunction (FunctionType dom cod) -> [dom, cod]
  TypeExprList lt -> [lt]
  TypeExprLiteral _ -> []
  TypeExprMap (MapType kt vt) -> [kt, vt]
  TypeExprNominal _ -> []
  TypeExprOptional ot -> [ot]
  TypeExprRecord fields -> fieldTypeType <$> fields
  TypeExprSet st -> [st]
  TypeExprUnion fields -> fieldTypeType <$> fields
  TypeExprUniversal (UniversalType v body) -> [body]
  TypeExprVariable _ -> []

termDependencyNames :: Bool -> Bool -> Bool -> Term m -> S.Set Name
termDependencyNames withEls withPrims withNoms = foldOverTerm TraversalOrderPre addNames S.empty
  where
    addNames names term = case termData term of
      ExpressionElement name -> if withEls then S.insert name names else names
      ExpressionFunction (FunctionPrimitive name) -> if withPrims then S.insert name names else names
      ExpressionNominal (NominalTerm name _) -> if withNoms then S.insert name names else names
      _ -> names

topologicalSortElements :: [Element m] -> Maybe [Name]
topologicalSortElements els = topologicalSort $ adjlist <$> els
  where
    adjlist e = (elementName e, S.toList $ termDependencyNames True True True $ elementData e)

typeDependencies :: (Default m, Show m) => Context m -> Name -> Result (M.Map Name (Type m))
typeDependencies scx name = deps (S.fromList [name]) M.empty
  where
    deps seeds names = if S.null seeds
        then return names
        else do
          pairs <- CM.mapM toPair $ S.toList seeds
          let newNames = M.union names (M.fromList pairs)
          let refs = L.foldl S.union S.empty (typeDependencyNames <$> (snd <$> pairs))
          let visited = S.fromList $ M.keys names
          let newSeeds = S.difference refs visited
          deps newSeeds newNames
      where
        toPair name = do
          typ <- requireType scx name
          return (name, typ)

    requireType scx name = do
      el <- requireElement scx name
      decodeType scx (elementData el)

typeDependencyNames :: Type m -> S.Set Name
typeDependencyNames = foldOverType TraversalOrderPre addNames S.empty
  where
    addNames names typ = case typeData typ of
      TypeExprNominal name -> S.insert name names
      _ -> names
