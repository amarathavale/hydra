module Hydra.Dsl.Lib.Sets where

import Hydra.Phantoms
import qualified Hydra.Dsl.Terms as Terms
import Hydra.Sources.Libraries

import Data.Set


--add :: Datum (a -> Set a -> Set a)
--add = Datum $ Terms.primitive _sets_add

contains :: Datum (a -> Set a -> Bool)
contains = Datum $ Terms.primitive _sets_contains

isEmpty :: Datum (Set a -> Bool)
isEmpty = Datum $ Terms.primitive _sets_isEmpty

remove :: Datum (a -> Set a -> Set a)
remove = Datum $ Terms.primitive _sets_remove