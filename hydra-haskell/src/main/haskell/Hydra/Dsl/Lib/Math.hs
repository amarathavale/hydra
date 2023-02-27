module Hydra.Dsl.Lib.Math where

import Hydra.Phantoms
import Hydra.Sources.Libraries
import qualified Hydra.Dsl.Terms as Terms


add :: Datum (Int -> Int -> Int)
add = Datum $ Terms.primitive _math_add

div :: Datum (Int -> Int -> Int)
div = Datum $ Terms.primitive _math_div

mod :: Datum (Int -> Int -> Int)
mod = Datum $ Terms.primitive _math_mod

mul :: Datum (Int -> Int -> Int)
mul = Datum $ Terms.primitive _math_mul

neg :: Datum (Int -> Int)
neg = Datum $ Terms.primitive _math_neg

rem :: Datum (Int -> Int -> Int)
rem = Datum $ Terms.primitive _math_rem

sub :: Datum (Int -> Int -> Int)
sub = Datum $ Terms.primitive _math_sub
