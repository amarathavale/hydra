module Hydra.Impl.Haskell.Dsl.Bootstrap where

import Hydra.Core
import Hydra.Evaluation
import Hydra.Graph
import Hydra.CoreEncoding
import qualified Hydra.Impl.Haskell.Dsl.Types as Types
import Hydra.Meta
import Hydra.Rewriting

import qualified Data.Map as M
import qualified Data.Set as S


datatype :: Context Meta -> GraphName -> String -> Type Meta -> Element Meta
datatype cx gname lname typ = typeElement cx elName $ rewriteType replacePlaceholders id typ
  where
    elName = qualify gname (Name lname)
    
    -- Note: placeholders are only expected at the top level, or beneath annotations and/or type lambdas
    replacePlaceholders rec t = case t' of
        TypeRecord (RowType n fields) -> if n == Types.placeholderName
          then TypeRecord (RowType elName fields)
          else t'
        TypeUnion (RowType n fields) -> if n == Types.placeholderName
          then TypeUnion (RowType elName fields)
          else t'
        _ -> t'
      where
        t' = rec t

bootstrapContext :: Context Meta
bootstrapContext = cx
  where
    cx = Context {
      contextGraphs = GraphSet {
        graphSetGraphs = M.fromList [(emptyGraphName, emptyGraph)],
        graphSetRoot = emptyGraphName},
      contextElements = M.empty,
      contextFunctions = M.empty,
      contextStrategy = EvaluationStrategy {
        evaluationStrategyOpaqueTermVariants = S.fromList []},
      contextAnnotations = metaAnnotationClass,
      contextTrace = []}

    emptyGraphName = GraphName "empty"

    emptyGraph = Graph emptyGraphName [] emptyGraphName

nsref :: GraphName -> String -> Type m
nsref ns = Types.nominal . qualify ns . Name

qualify :: GraphName -> Name -> Name
qualify (GraphName gname) (Name lname) = Name $ gname ++ "." ++ lname

termElement :: Context Meta -> Name -> Type Meta -> Term Meta -> Element Meta
termElement cx name typ term = Element {
  elementName = name,
  elementSchema = encodeType cx typ,
  elementData = term}

typeElement :: Context Meta -> Name -> Type Meta -> Element Meta
typeElement cx name typ = Element {
  elementName = name,
  elementSchema = TermElement _Type,
  elementData = encodeType cx typ}
