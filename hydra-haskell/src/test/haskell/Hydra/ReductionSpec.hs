module Hydra.ReductionSpec where

import Hydra.Core
import Hydra.Impl.Haskell.Dsl.CoreMeta
import Hydra.Reduction
import Hydra.Impl.Haskell.Dsl.Terms
import qualified Hydra.Impl.Haskell.Dsl.Types as Types
import Hydra.Primitives

import Hydra.TestUtils
import Hydra.TestData

import qualified Test.Hspec as H
import qualified Test.QuickCheck as QC
import qualified Data.List as L
import qualified Data.Char as C


checkLiterals :: H.SpecWith ()
checkLiterals = do
  H.describe "Tests for literal values" $ do

    H.it "Literal terms have no free variables" $
      QC.property $ \av -> termIsClosed (literal av :: Term Meta)

    H.it "Literal terms are fully reduced; check using a dedicated function" $
      QC.property $ \av -> termIsValue testStrategy (literal av :: Term Meta)

    H.it "Literal terms are fully reduced; check by trying to reduce them" $
      QC.property $ \av ->
        H.shouldBe
          (eval (literal av))
          (pure (literal av :: Term Meta))

    H.it "Literal terms cannot be applied" $
      QC.property $ \av (TypedTerm _ term) -> isFailure (eval $ apply (literal av) term)

checkMonomorphicPrimitives :: H.SpecWith ()
checkMonomorphicPrimitives = do
  H.describe "Tests for monomorphic primitive functions" $ do

    H.it "Example primitives have the expected arity" $ do
      H.shouldBe
        (primitiveFunctionArity <$> lookupPrimitiveFunction testContext _strings_toUpper)
        (Just 1)
      H.shouldBe
        (primitiveFunctionArity <$> lookupPrimitiveFunction testContext _strings_splitOn)
        (Just 2)

    H.it "Simple applications of a unary function succeed" $
      QC.property $ \s ->
        H.shouldBe
          (eval (apply (primitive _strings_toUpper) $ string s))
          (pure (string $ fmap C.toUpper s))

    H.it "Simple applications of a binary function succeed" $
      QC.property $ \i1 i2 ->
        H.shouldBe
          (eval (apply (apply (primitive _math_add) $ int32 i1) $ int32 i2))
          (pure (int32 $ i1 + i2))

    H.it "Incomplete application of a primitive function leaves the term unchanged" $
      QC.property $ \s1 ->
        H.shouldBe
          (eval (apply (primitive _strings_splitOn) $ string s1))
          (pure (apply (primitive _strings_splitOn) $ string s1))

    H.it "Extra arguments to a primitive function cause failure" $
      QC.property $ \s1 s2 ->
        isFailure (eval (apply (apply (primitive _strings_toUpper) $ string s1) $ string s2))

checkPolymorphicPrimitives :: H.SpecWith ()
checkPolymorphicPrimitives = do
  H.describe "Tests for polymorphic primitive functions" $ do

    H.it "Test polymorphic list length" $ do
      QC.property $ \l ->
        H.shouldBe
          (eval (apply (primitive _lists_length) $ list l))
          (pure (int32 $ L.length l))

testBetaReduceTypeRecursively :: H.SpecWith ()
testBetaReduceTypeRecursively = do
  H.describe "Beta reduce types recursively" $ do
    
    H.it "Try non-application types" $ do
      H.shouldBe
        (reduce True Types.unit :: Type Meta)
        Types.unit
      H.shouldBe
        (reduce False latLonType :: Type Meta)
        latLonType

    H.it "Try simple application types" $ do
      H.shouldBe
        (reduce False app1)
        (Types.function Types.string Types.string)
      H.shouldBe
        (reduce False app2)
        latLonType
      H.shouldBe
        (reduce False app3)
        (Types.record [Types.field "foo" Types.unit])
        
    H.it "Try recursive application types" $ do
      H.shouldBe
        (reduce False app4)
        (Types.record [Types.field "f1" Types.int32, Types.field "f2" Types.int64])
        
    H.it "Distinguish between eager and lazy evaluation" $ do
      H.shouldBe
        (reduce False app5)
        (Types.record [Types.field "foo" app1])
      H.shouldBe
        (reduce True app5)
        (Types.record [Types.field "foo" $ Types.function Types.string Types.string])
  where
    ResultSuccess scx = schemaContext testContext
    reduce eager = betaReduceType eager scx 
    app1 = Types.apply (Types.lambda "t" $ Types.function (Types.variable "t") (Types.variable "t")) Types.string :: Type Meta
    app2 = Types.apply (Types.lambda "x" latLonType) Types.int32 :: Type Meta
    app3 = Types.apply (Types.lambda "a" $ Types.record [Types.field "foo" $ Types.variable "a"]) Types.unit :: Type Meta
    app4 = Types.apply (Types.apply (Types.lambda "x" $ Types.lambda "y" $ Types.record [
      Types.field "f1" $ Types.variable "x",
      Types.field "f2" $ Types.variable "y"]) Types.int32) Types.int64 :: Type Meta
    app5 = Types.apply (Types.lambda "a" $ Types.record [Types.field "foo" $ Types.variable "a"]) app1

eval :: Term Meta -> Result (Term Meta)
eval = betaReduceTerm testContext

spec :: H.Spec
spec = do
  testBetaReduceTypeRecursively
  checkLiterals
  checkMonomorphicPrimitives
  checkPolymorphicPrimitives