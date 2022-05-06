module Hydra.Impl.Haskell.Dsl.CoreMeta (
  nominalCases,
  nominalMatch,
  nominalMatchWithVariants,
  nominalProjection,
  nominalRecord,
  nominalTerm,
  nominalUnion,
  nominalUnitVariant,
  nominalVariant,
  nominalWithFunction,
  nominalWithUnitVariant,
  nominalWithVariant,
  withDoc,
  withType,
  module Hydra.Impl.Haskell.Dsl.Terms,
) where

import Hydra.Core
import Hydra.Evaluation
import Hydra.Graph
import Hydra.Impl.Haskell.Dsl.Terms
import qualified Hydra.Impl.Haskell.Dsl.Types as Types
import Hydra.Impl.Haskell.Extras


nominalCases :: Default m => Context m -> Name -> Type m -> [Field m] -> Term m
nominalCases cx name cod fields = withType cx (Types.function (Types.nominal name) cod) $ cases fields

nominalMatch :: Default m => Context m -> Name -> Type m -> [(FieldName, Term m)] -> Term m
nominalMatch cx name cod fields = nominalCases cx name cod (fmap toField fields)
  where
    toField (fname, term) = Field fname term

nominalMatchWithVariants :: Context Meta -> Type Meta -> Type Meta -> [(FieldName, FieldName)] -> Term Meta
nominalMatchWithVariants cx dom cod = withType cx ft . cases . fmap toField
  where
    ft = Types.function dom cod
    toField (from, to) = Field from $ constFunction $ withType cx cod $ unitVariant to -- nominalUnitVariant cx cod to

nominalProjection :: Default m => Context m -> Name -> FieldName -> Type m -> Term m
nominalProjection cx name fname ftype = withType cx (Types.function (Types.nominal name) ftype) $ projection fname

nominalRecord :: Default m => Context m -> Name -> [Field m] -> Term m
nominalRecord cx name fields = nominalTerm cx name $ record fields

nominalTerm :: Default m => Context m -> Name -> Term m -> Term m
nominalTerm cx name = withType cx (Types.nominal name)

nominalUnion :: Default m => Context m -> Name -> Field m -> Term m
nominalUnion cx name field = withType cx (Types.nominal name) $ union field

nominalUnitVariant :: Default m => Context m -> Name -> FieldName -> Term m
nominalUnitVariant cx name fname = nominalVariant cx name fname unitTerm

nominalVariant :: Default m => Context m -> Name -> FieldName -> Term m -> Term m
nominalVariant cx name fname term = nominalTerm cx name $ variant fname term

nominalWithFunction :: Default m => Context m -> Name -> FieldName -> Element m -> Term m
nominalWithFunction cx name fname el = lambda var $ nominalVariant cx name fname $ apply (elementRef el) (variable var)
  where var = "x"

nominalWithUnitVariant :: Default m => Context m -> Name -> FieldName -> Term m
nominalWithUnitVariant cx name fname = constFunction $ nominalUnitVariant cx name fname

nominalWithVariant :: Default m => Context m -> Name -> FieldName -> Term m -> Term m
nominalWithVariant cx name fname term = constFunction $ nominalVariant cx name fname term

withType :: Context m -> Type m -> Term m -> Term m
withType cx typ term = term { termMeta = contextSetTypeOf cx (Just typ) (termMeta term)}

withDoc :: String -> Term Meta -> Term Meta
withDoc desc term = term { termMeta = (termMeta term) {metaDescription = Just desc}}
