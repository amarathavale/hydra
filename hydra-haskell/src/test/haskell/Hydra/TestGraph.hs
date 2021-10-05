module Hydra.TestGraph (
  graphElementsMap,
  testContext,
  testGraph,
  testStrategy,
) where

import Hydra.Core
import Hydra.Graph
import Hydra.Evaluation
import Hydra.Prototyping.Basics
import Hydra.Ext.Haskell.Dsl
import Hydra.Prototyping.Primitives
import Hydra.Prototyping.CoreEncoding

import qualified Data.Char as C
import qualified Data.List as L
import qualified Data.Map  as M
import qualified Data.Set  as S


testContext :: Context
testContext = Context {
    contextGraphs = GraphSet {
      graphSetGraphs = M.fromList [
        ("testGraph", testGraph),
        ("testSchemaGraph", testSchemaGraph),
        ("hydra/core", hydraCorePlaceholder)],
      graphSetRoot = "testGraph"},
    contextElements = graphElementsMap testGraph,
    contextFunctions = M.fromList [
      ("concat", PrimitiveFunction concatFunction (FunctionType stringType (TypeFunction $ FunctionType stringType stringType))),
      ("toLower", PrimitiveFunction toLowerFunction (FunctionType stringType stringType)),
      ("toUpper", PrimitiveFunction toUpperFunction (FunctionType stringType stringType))],
    contextStrategy = EvaluationStrategy {
      evaluationStrategyOpaqueTermVariants = S.fromList [ -- TODO: revisit this list
        TermVariantAtomic,
        TermVariantCases,
        TermVariantData,
        TermVariantElement,
        TermVariantFunction,
        TermVariantLambda,
        TermVariantProjection]}}

concatFunction :: [Term] -> Term
concatFunction [x, y] = case (x, y) of
  (TermAtomic (AtomicValueString x'), TermAtomic (AtomicValueString y'))
    -> TermAtomic $ AtomicValueString $ x' ++ y'

toLowerFunction :: [Term] -> Term
toLowerFunction [x] = case x of
  TermAtomic (AtomicValueString s)
    -> TermAtomic $ AtomicValueString $ fmap C.toLower s

toUpperFunction :: [Term] -> Term
toUpperFunction [x] = case x of
  TermAtomic (AtomicValueString s)
    -> TermAtomic $ AtomicValueString $ fmap C.toUpper s

testGraph :: Graph
testGraph = Graph "testGraph" [arthur] allTerms "testSchemaGraph"
  where
    arthur = Element {
      elementName = "ArthurDent",
      elementSchema = TermElement "Person",
      elementData = TermRecord [
        Field "firstName" $ stringValue "Arthur",
        Field "lastName" $ stringValue "Dent",
        Field "age" $ int32Value 42]}

testSchemaGraph :: Graph
testSchemaGraph = Graph "testSchemaGraph" [exampleNominalType] allTerms "hydra/core"
  where
    exampleNominalType = typeElement "StringTypeAlias" stringType
    exampleVertexType = typeElement "Person" $
      TypeRecord [
        FieldType "firstName" stringType,
        FieldType "lastName" stringType,
        FieldType "age" int32Type]

testStrategy :: EvaluationStrategy
testStrategy = contextStrategy testContext

-- Note: here, the element namespace "hydra/core" doubles as a graph name
hydraCorePlaceholder :: Graph
hydraCorePlaceholder = Graph "hydra/core" noElements allTerms "hydra/core"

noElements :: [Element]
noElements = []

allTerms :: Term -> Bool
allTerms _ = True

typeElement :: Name -> Type -> Element
typeElement name typ = Element {
  elementName = name,
  elementSchema = encodeType $ TypeNominal "hydra/core.Type",
  elementData = encodeType typ}
