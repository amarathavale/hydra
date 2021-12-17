module Hydra.Impl.Haskell.Sources.Adapters.Utils (adaptersUtilsGraph) where

import Hydra.Core
import Hydra.Impl.Haskell.Sources.Libraries
import Hydra.Graph
import Hydra.Impl.Haskell.Dsl.Terms
import Hydra.Impl.Haskell.Dsl.Standard
import Hydra.Impl.Haskell.Extras
import Hydra.Impl.Haskell.Sources.Basics


(++.) :: Default a => Term a -> Term a -> Term a
l ++. r = apply (primitive _strings_cat) $ list [l, r]

(@.) :: Default a => Term a -> Term a -> Term a 
l @. r = apply l r

(->.) :: Default a => Variable -> Term a -> Term a
v ->. body = lambda v body

const_ :: Default a => Term a -> Term a
const_ = constFunction

e_ :: Default a1 => Element a2 -> Term a1
e_ el = element $ elementName el

l_ :: Default a => Variable -> Term a -> Term a
l_ = lambda

match_ :: Name -> Type -> [(FieldName, Term Meta)] -> Term Meta
match_ = standardMatch

p_ :: Default a => Name -> Term a
p_ = primitive

s_ :: String -> Term Meta
s_ = stringValue

string_ :: Type
string_ = stringType

t_ :: Name -> Type
t_ = nominalType

v_ :: Default a => Variable -> Term a
v_ = variable


_hydra_adapters_utils :: Name
_hydra_adapters_utils = "hydra/adapters/utils"

adaptersUtilsGraph :: Graph Meta
adaptersUtilsGraph = standardGraph _hydra_adapters_utils [
  describeFloatType,
  describePrecision]

describeFloatType :: Element Meta
describeFloatType = standardFunction _hydra_adapters_utils "describeFloatType"
  "Display a floating-point type as a string"
  (t_ _FloatType) string_
  $ l_"t" $ (e_ describePrecision @. (e_ floatTypePrecision @. v_"t")) ++. s_" floating-point numbers"

describePrecision :: Element Meta
describePrecision = standardFunction _hydra_adapters_utils "describePrecision"
  "Display numeric precision as a string"
  (t_ _Precision) string_ $
  match_ _Precision string_ [
    (_Precision_arbitrary, constFunction $ s_"arbitrary-precision"),
    (_Precision_bits,
      l_"bits" $ p_ _strings_cat @.
        list [
          p_ _literals_showInt32 @. v_"bits",
          s_"-bit"])]