-- | A DSL for constructing literal types and terms

module Hydra.Dsl.Literals where

import Hydra.Compute
import Hydra.Core
import Hydra.Flows

import Data.Int


bigfloat :: Double -> Literal
bigfloat = float . FloatValueBigfloat

bigint :: Integer -> Literal
bigint = integer . IntegerValueBigint . fromIntegral

binary :: String -> Literal
binary = LiteralBinary

boolean :: Bool -> Literal
boolean = LiteralBoolean

float32 :: Float -> Literal
float32 = float . FloatValueFloat32

float64 :: Double -> Literal
float64 = float . FloatValueFloat64

float :: FloatValue -> Literal
float = LiteralFloat

int16 :: Int16 -> Literal
int16 = integer . IntegerValueInt16 . fromIntegral

int32 :: Int -> Literal
int32 = integer . IntegerValueInt32

int64 :: Int64 -> Literal
int64 = integer . IntegerValueInt64 . fromIntegral

int8 :: Int8 -> Literal
int8 = integer . IntegerValueInt8 . fromIntegral

integer :: IntegerValue -> Literal
integer = LiteralInteger

string :: String -> Literal
string = LiteralString

uint16 :: Integer -> Literal
uint16 = integer . IntegerValueUint16 . fromIntegral

uint32 :: Integer -> Literal
uint32 = integer . IntegerValueUint32 . fromIntegral

uint64 :: Integer -> Literal
uint64 = integer . IntegerValueUint64 . fromIntegral

uint8 :: Integer -> Literal
uint8 = integer . IntegerValueUint8 . fromIntegral
