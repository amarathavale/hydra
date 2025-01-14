{-# LANGUAGE OverloadedStrings #-}

module Hydra.Sources.Libraries where

import Hydra.Kernel
import Hydra.Dsl.Prims as Prims
import qualified Hydra.Dsl.Terms as Terms
import qualified Hydra.Dsl.Types as Types

import qualified Hydra.Lib.Flows as Flows
import qualified Hydra.Lib.Lists as Lists
import qualified Hydra.Lib.Literals as Literals
import qualified Hydra.Lib.Maps as Maps
import qualified Hydra.Lib.Math as Math
import qualified Hydra.Lib.Optionals as Optionals
import qualified Hydra.Lib.Sets as Sets
import qualified Hydra.Lib.Strings as Strings


_hydra_lib_flows :: Namespace
_hydra_lib_flows = Namespace "hydra/lib/flows"

_flows_apply :: Name
_flows_apply = qname _hydra_lib_flows "apply"

_flows_bind :: Name
_flows_bind = qname _hydra_lib_flows "bind"

_flows_map :: Name
_flows_map = qname _hydra_lib_flows "map"

_flows_pure :: Name
_flows_pure = qname _hydra_lib_flows "pure"

_hydra_lib_io :: Namespace
_hydra_lib_io = Namespace "hydra/lib/io"

_io_showTerm :: Name
_io_showTerm = qname _hydra_lib_io "showTerm"

_io_showType :: Name
_io_showType = qname _hydra_lib_io "showType"

_hydra_lib_lists :: Namespace
_hydra_lib_lists = Namespace "hydra/lib/lists"

_lists_apply :: Name
_lists_apply = qname _hydra_lib_lists "apply"

_lists_bind :: Name
_lists_bind = qname _hydra_lib_lists "bind"

_lists_concat :: Name
_lists_concat = qname _hydra_lib_lists "concat"

_lists_head :: Name
_lists_head = qname _hydra_lib_lists "head"

_lists_intercalate :: Name
_lists_intercalate = qname _hydra_lib_lists "intercalate"

_lists_intersperse :: Name
_lists_intersperse = qname _hydra_lib_lists "intersperse"

_lists_last :: Name
_lists_last = qname _hydra_lib_lists "last"

_lists_length :: Name
_lists_length = qname _hydra_lib_lists "length"

_lists_map :: Name
_lists_map = qname _hydra_lib_lists "map"

_lists_pure :: Name
_lists_pure = qname _hydra_lib_lists "pure"

_hydra_lib_literals :: Namespace
_hydra_lib_literals = Namespace "hydra/lib/literals"

_literals_showInt32 :: Name
_literals_showInt32 = qname _hydra_lib_literals "showInt32"

_literals_showString :: Name
_literals_showString = qname _hydra_lib_literals "showString"

_hydra_lib_maps :: Namespace
_hydra_lib_maps = Namespace "hydra/lib/maps"

_maps_empty :: Name
_maps_empty = qname _hydra_lib_maps "empty"

_maps_fromList :: Name
_maps_fromList = qname _hydra_lib_maps "fromList"

_maps_insert :: Name
_maps_insert = qname _hydra_lib_maps "insert"

_maps_isEmpty :: Name
_maps_isEmpty = qname _hydra_lib_maps "isEmpty"

_maps_lookup :: Name
_maps_lookup = qname _hydra_lib_maps "lookup"

_maps_map :: Name
_maps_map = qname _hydra_lib_maps "map"

_maps_remove :: Name
_maps_remove = qname _hydra_lib_maps "remove"

_maps_singleton :: Name
_maps_singleton = qname _hydra_lib_maps "singleton"

_maps_size :: Name
_maps_size = qname _hydra_lib_maps "size"

_maps_toList :: Name
_maps_toList = qname _hydra_lib_maps "toList"

_hydra_lib_math :: Namespace
_hydra_lib_math = Namespace "hydra/lib/math"

_math_add :: Name
_math_add = qname _hydra_lib_math "add"

_math_div :: Name
_math_div = qname _hydra_lib_math "div"

_math_mod :: Name
_math_mod = qname _hydra_lib_math "mod"

_math_mul :: Name
_math_mul = qname _hydra_lib_math "mul"

_math_neg :: Name
_math_neg = qname _hydra_lib_math "neg"

_math_rem :: Name
_math_rem = qname _hydra_lib_math "rem"

_math_sub :: Name
_math_sub = qname _hydra_lib_math "sub"

_hydra_lib_optionals :: Namespace
_hydra_lib_optionals = Namespace "hydra/lib/optionals"

_optionals_apply :: Name
_optionals_apply = qname _hydra_lib_optionals "apply"

_optionals_bind :: Name
_optionals_bind = qname _hydra_lib_optionals "bind"

_optionals_map :: Name
_optionals_map = qname _hydra_lib_optionals "map"

_optionals_pure :: Name
_optionals_pure = qname _hydra_lib_optionals "pure"

_hydra_lib_sets :: Namespace
_hydra_lib_sets = Namespace "hydra/lib/sets"

_sets_insert :: Name
_sets_insert = qname _hydra_lib_sets "add"

_sets_contains :: Name
_sets_contains = qname _hydra_lib_sets "contains"

_sets_empty :: Name
_sets_empty = qname _hydra_lib_sets "empty"

_sets_fromList :: Name
_sets_fromList = qname _hydra_lib_sets "fromList"

_sets_isEmpty :: Name
_sets_isEmpty = qname _hydra_lib_sets "isEmpty"

_sets_map :: Name
_sets_map = qname _hydra_lib_sets "map"

_sets_remove :: Name
_sets_remove = qname _hydra_lib_sets "remove"

_sets_singleton :: Name
_sets_singleton = qname _hydra_lib_sets "pure"

_sets_size :: Name
_sets_size = qname _hydra_lib_sets "size"

_sets_toList :: Name
_sets_toList = qname _hydra_lib_sets "toList"

_hydra_lib_strings :: Namespace
_hydra_lib_strings = Namespace "hydra/lib/strings"

_strings_cat :: Name
_strings_cat = qname _hydra_lib_strings "cat"

_strings_length :: Name
_strings_length = qname _hydra_lib_strings "length"

_strings_splitOn :: Name
_strings_splitOn = qname _hydra_lib_strings "splitOn"

_strings_toLower :: Name
_strings_toLower = qname _hydra_lib_strings "toLower"

_strings_toUpper :: Name
_strings_toUpper = qname _hydra_lib_strings "toUpper"

--hydraIoPrimitives = [
--  prim1 _io_showTerm (variable "a) string
--  ]

hydraLibFlowsPrimitives :: (Ord a, Show a) => [Primitive a]
hydraLibFlowsPrimitives = [
    prim2 _flows_apply (flow s (function x y)) (flow s x) (flow s y) Flows.apply,
    prim2 _flows_bind (flow s x) (function x (flow s y)) (flow s y) Flows.bind,
    prim2 _flows_map (function x y) (flow s x) (flow s y) Flows.map,
    prim1 _flows_pure x (flow s x) Flows.pure]
  where
    s = variable "s"
    x = variable "x"
    y = variable "y"
    
hydraLibListsPrimitives :: (Ord a, Show a) => [Primitive a]
hydraLibListsPrimitives = [
    prim2Raw _lists_apply (list $ function x y) (list x) (list y) Lists.applyRaw,
    prim2Raw _lists_bind (list x) (function x (list y)) (list y) Lists.bindRaw,
    prim1 _lists_concat (list (list x)) (list x) Lists.concat,
    prim1 _lists_head (list x) x Lists.head,
    prim2 _lists_intercalate (list x) (list (list x)) (list x) Lists.intercalate,
    prim2 _lists_intersperse x (list x) (list x) Lists.intersperse,
    prim1 _lists_last (list x) x Lists.last,
    prim1 _lists_length (list x) int32 Lists.length,
    prim2Raw _lists_map (function x y) (list x) (list y) Lists.mapRaw,
    prim1 _lists_pure x (list x) Lists.pure]
  where
    x = variable "x"
    y = variable "y"

hydraLibLiteralsPrimitives :: Show a => [Primitive a]
hydraLibLiteralsPrimitives = [
  prim1 _literals_showInt32 int32 string Literals.showInt32,
  prim1 _literals_showString string string Literals.showString]

hydraLibMapsPrimitives :: (Ord a, Show a) => [Primitive a]
hydraLibMapsPrimitives = [
    prim0 _maps_empty mapKv Maps.empty,
    prim1 _maps_fromList (list $ pair k v) mapKv Maps.fromList,
    prim3 _maps_insert k v mapKv mapKv Maps.insert,
    prim1 _maps_isEmpty mapKv boolean Maps.isEmpty,
    prim2 _maps_lookup k mapKv (optional v) Maps.lookup,
    prim2 _optionals_map (function v1 v2) (Prims.map k v1) (Prims.map k v2) Maps.map,
    prim1 _maps_size mapKv int32 Maps.size,
    prim2 _maps_remove k mapKv mapKv Maps.remove,
    prim2 _maps_singleton k v mapKv Maps.singleton,
    prim1 _maps_size mapKv int32 Maps.size,
    prim1 _maps_toList mapKv (list $ pair k v) Maps.toList]
  where
    k = variable "k"
    v = variable "v"
    v1 = variable "v1"
    v2 = variable "v2"
    mapKv = Prims.map k v

hydraLibMathInt32Primitives :: Show a => [Primitive a]
hydraLibMathInt32Primitives = [
  prim2 _math_add int32 int32 int32 Math.add,
  prim2 _math_div int32 int32 int32 Math.div,
  prim2 _math_mod int32 int32 int32 Math.mod,
  prim2 _math_mul int32 int32 int32 Math.mul,
  prim1 _math_neg int32 int32 Math.neg,
  prim2 _math_rem int32 int32 int32 Math.rem,
  prim2 _math_sub int32 int32 int32 Math.sub]

hydraLibOptionalsPrimitives :: (Ord a, Show a) => [Primitive a]
hydraLibOptionalsPrimitives = [
    prim2 _optionals_apply (optional $ function x y) (optional x) (optional y) Optionals.apply,
    prim2 _optionals_bind (optional x) (function x (optional y)) (optional y) Optionals.bind,
    prim2 _optionals_map (function x y) (optional x) (optional y) Optionals.map,
    prim1 _optionals_pure x (optional x) Optionals.pure]
  where
    x = variable "x"
    y = variable "y"

hydraLibSetsPrimitives :: (Ord a, Show a) => [Primitive a]
hydraLibSetsPrimitives = [
    prim2 _sets_contains x (set x) boolean Sets.contains,
    prim0 _sets_empty (set x) Sets.empty,
    prim1 _sets_fromList (list x) (set x) Sets.fromList,
    prim2 _sets_insert x (set x) (set x) Sets.insert,
    prim1 _sets_isEmpty (set x) boolean Sets.isEmpty,
    prim2 _sets_map (function x y) (set x) (set y) Sets.map,
    prim2 _sets_remove x (set x) (set x) Sets.remove,
    prim1 _sets_singleton x (set x) Sets.singleton,
    prim1 _sets_size (set x) int32 Sets.size,
    prim1 _sets_toList (set x) (list x) Sets.toList]
  where
    x = variable "x"
    y = variable "y"

hydraLibStringsPrimitives :: Show a => [Primitive a]
hydraLibStringsPrimitives = [
  prim1 _strings_cat (list string) string Strings.cat,
  prim1 _strings_length string int32 Strings.length,
  prim2 _strings_splitOn string string (list string) Strings.splitOn,
  prim1 _strings_toLower string string Strings.toLower,
  prim1 _strings_toUpper string string Strings.toUpper]

standardPrimitives :: (Ord a, Show a) => [Primitive a]
standardPrimitives =
     hydraLibFlowsPrimitives
  ++ hydraLibListsPrimitives
  ++ hydraLibLiteralsPrimitives
  ++ hydraLibMapsPrimitives
  ++ hydraLibMathInt32Primitives
  ++ hydraLibOptionalsPrimitives
  ++ hydraLibSetsPrimitives
  ++ hydraLibStringsPrimitives
