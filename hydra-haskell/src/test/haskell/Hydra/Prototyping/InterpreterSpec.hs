module Hydra.Prototyping.InterpreterSpec where

import Hydra.Core
import Hydra.Graph
import Hydra.Ext.Haskell.Dsl
import Hydra.Prototyping.Interpreter
import Hydra.Prototyping.Primitives

import Hydra.ArbitraryCore
import Hydra.TestGraph

import qualified Test.Hspec as H
import qualified Data.Char as C
import qualified Data.Either as E
import qualified Data.Set as S
import qualified Test.QuickCheck as QC


testEvaluate :: Term -> Either String Term
testEvaluate = evaluate testContext

testsForAtomicValues = do
  H.describe "Tests for atomic values" $ do
    
    H.it "Atomic terms have no free variables" $
      QC.property $ \av -> termIsClosed (TermAtomic av)

    H.it "Atomic terms are fully reduced; check using a dedicated function" $
      QC.property $ \av -> termIsValue testStrategy (TermAtomic av)

    H.it "Atomic terms are fully reduced; check by trying to reduce them" $
      QC.property $ \av -> testEvaluate (TermAtomic av) == (Right (TermAtomic av))

    H.it "Atomic terms cannot be applied" $
      QC.property $ \av term -> E.isLeft (testEvaluate $ apply (TermAtomic av) term)

testsForPrimitiveFunctions = do
  H.describe "Tests for primitive functions" $ do
    
    H.it "Example primitives have the expected arity" $ do
      (primitiveFunctionArity <$> lookupPrimitiveFunction testContext "toUpper") `H.shouldBe` (Just 1)
      (primitiveFunctionArity <$> lookupPrimitiveFunction testContext "concat") `H.shouldBe` (Just 2)
    
    H.it "Simple applications of a unary function succeed" $
      QC.property $ \s -> 
        (testEvaluate (apply (function "toUpper") $ stringTerm s))
        == (Right $ stringTerm $ fmap C.toUpper s)
        
    H.it "Simple applications of a binary function succeed" $
      QC.property $ \s1 s2 ->
        (testEvaluate (apply (apply (function "concat") $ stringTerm s1) $ stringTerm s2))
        == (Right $ stringTerm $ s1 ++ s2)

    H.it "Incomplete application of a primitive function leaves the term unchanged" $ 
      QC.property $ \s1 ->
        (testEvaluate (apply (function "concat") $ stringTerm s1))
        == (Right $ apply (function "concat") $ stringTerm s1)

    H.it "Extra arguments to a primitive function cause failure" $
      QC.property $ \s1 s2 ->
        E.isLeft (testEvaluate (apply (apply (function "toUpper") $ stringTerm s1) $ stringTerm s2))

spec :: H.Spec
spec = do
  testsForAtomicValues
  testsForPrimitiveFunctions
