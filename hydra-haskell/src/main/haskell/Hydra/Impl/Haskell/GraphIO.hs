module Hydra.Impl.Haskell.GraphIO where

import Hydra.Core
import Hydra.Evaluation
import Hydra.Graph
import Hydra.Impl.Haskell.Dsl.Standard
import Hydra.Monads
import Hydra.Lexical
import Hydra.CoreEncoding
import Hydra.Types.Inference
import Hydra.Util.Formatting

import qualified Hydra.Ext.Haskell.Coder as Haskell
import qualified Hydra.Ext.Java.Coder as Java
import qualified Hydra.Ext.Pegasus.Coder as PDL
import qualified Hydra.Ext.Scala.Coder as Scala

import Hydra.Impl.Haskell.Sources.Adapter
import Hydra.Impl.Haskell.Sources.Adapters.Utils
import Hydra.Impl.Haskell.Sources.Basics
import Hydra.Impl.Haskell.Sources.Core
import Hydra.Impl.Haskell.Sources.Evaluation
import Hydra.Impl.Haskell.Sources.Phantoms
import Hydra.Impl.Haskell.Sources.Graph
import Hydra.Impl.Haskell.Sources.Grammar
import Hydra.Impl.Haskell.Sources.Libraries

import Hydra.Impl.Haskell.Sources.Util.Codetree.Ast
import Hydra.Impl.Haskell.Sources.Ext.Coq.Syntax
import Hydra.Impl.Haskell.Sources.Ext.Datalog.Syntax
import Hydra.Impl.Haskell.Sources.Ext.Graphql.Syntax
import Hydra.Impl.Haskell.Sources.Ext.Haskell.Ast
import Hydra.Impl.Haskell.Sources.Ext.Java.Syntax
import Hydra.Impl.Haskell.Sources.Ext.Json.Model
import Hydra.Impl.Haskell.Sources.Ext.Pegasus.Pdl
import Hydra.Impl.Haskell.Sources.Ext.Owl.Syntax
import Hydra.Impl.Haskell.Sources.Ext.Scala.Meta
import Hydra.Impl.Haskell.Sources.Ext.Tinkerpop.Features
import Hydra.Impl.Haskell.Sources.Ext.Tinkerpop.Typed
import Hydra.Impl.Haskell.Sources.Ext.Tinkerpop.V3
import Hydra.Impl.Haskell.Sources.Ext.Xml.Schema
import Hydra.Impl.Haskell.Sources.Ext.Yaml.Model
import Hydra.Impl.Haskell.Sources.Ext.Rdf.Syntax
import Hydra.Impl.Haskell.Sources.Ext.Shacl.Model

import qualified Control.Monad as CM
import qualified System.FilePath as FP
import qualified Data.List as L
import qualified Data.Map as M
import qualified System.Directory as SD
import qualified Data.Maybe as Y


addDeepTypeAnnotations :: Module Meta -> GraphFlow Meta (Module Meta)
addDeepTypeAnnotations mod = do
    els <- CM.mapM annotateElementWithTypes $ graphElements g
    return $ mod {moduleGraph = g {graphElements = els}}
  where
    g = moduleGraph mod

allModules :: [Module Meta]
allModules = coreModules ++ extModules

assignSchemas :: Bool -> Module Meta -> GraphFlow Meta (Module Meta)
assignSchemas doInfer mod = do
    cx <- getState
    els <- CM.mapM (annotate cx) $ graphElements g
    return $ mod {moduleGraph = g {graphElements = els}}
  where
    g = moduleGraph mod

    annotate cx el = do
      typ <- findType cx (elementData el)
      case typ of
        Nothing -> if doInfer
          then do
            t <- typeSchemeType . snd <$> inferType (elementData el)
            return el {elementSchema = encodeType t}
          else return el
        Just typ -> return el {elementSchema = encodeType typ}

coreModules :: [Module Meta]
coreModules = [
  adapterUtilsModule,
  codetreeAstModule,
  haskellAstModule,
  hydraAdapterModule,
  hydraBasicsModule,
  hydraCoreModule,
  hydraEvaluationModule,
  hydraGraphModule,
  hydraGrammarModule,
--  hydraMonadsModule,
  hydraPhantomsModule,
  jsonModelModule]

extModules :: [Module Meta]
extModules = [
  coqSyntaxModule,
  datalogSyntaxModule,
  graphqlSyntaxModule,
  javaSyntaxModule,
  pegasusPdlModule,
  owlSyntaxModule,
  rdfSyntaxModule,
  scalaMetaModule,
  shaclModelModule,
  tinkerpopFeaturesModule,
  tinkerpopTypedModule,
  tinkerpopV3Module,
  xmlSchemaModule,
  yamlModelModule]

findType :: Context Meta -> Term Meta -> GraphFlow Meta (Maybe (Type Meta))
findType cx term = annotationClassTermType (contextAnnotations cx) term

generateSources :: (Graph Meta -> GraphFlow Meta (M.Map FilePath String)) -> [Module Meta] -> FilePath -> IO ()
generateSources printGraph mods0 basePath = do
    mfiles <- runFlow coreContext generateFiles
    case mfiles of
      Nothing -> fail "Transformation failed"
      Just files -> mapM_ writePair files
  where
    generateFiles = do
      withTrace "generate files" $ do
        mods1 <- CM.mapM (assignSchemas False) mods0
        withState (modulesToContext mods1) $ do
-- TODO         mods2 <- CM.mapM addDeepTypeAnnotations mods1
--          let mods2 = mods1
          mods2 <- CM.mapM (assignSchemas True) mods1
          maps <- CM.mapM (printGraph . moduleGraph) mods2
          return $ L.concat (M.toList <$> maps)

    writePair (path, s) = do
      let fullPath = FP.combine basePath path
      SD.createDirectoryIfMissing True $ FP.takeDirectory fullPath
      writeFile fullPath s

modulesToContext :: [Module Meta] -> Context Meta
modulesToContext mods = setContextElements allGraphs $ coreContext {
    contextGraphs = GraphSet allGraphsByName rootGraphName,
    contextFunctions = M.fromList $ fmap (\p -> (primitiveFunctionName p, p)) standardPrimitives}
  where
    rootGraphName = hydraCoreName -- Note: this assumes that all schema graphs are the same
    allGraphs = moduleGraph <$> M.elems allModules
    allGraphsByName = M.fromList $ (\g -> (graphName g, g)) <$> allGraphs
    allModules = L.foldl addModule (M.fromList [(hydraCoreName, hydraCoreModule)]) mods
      where
        addModule m mod@(Module g' deps) = if M.member gname m
            then m
            else L.foldl addModule (M.insert gname mod m) deps
          where
            gname = graphName g'

printTrace :: Bool -> Trace -> IO ()
printTrace isError t = do
  if not (L.null $ traceMessages t)
    then do
      putStrLn $ if isError then "Flow failed. Messages:" else "Messages:"
      putStrLn $ indentLines $ traceSummary t
    else pure ()

runFlow :: s -> Flow s a -> IO (Maybe a)
runFlow cx f = do
  let FlowWrapper v _ t = unFlow f cx emptyTrace
  printTrace (Y.isNothing v) t
  return v

writeHaskell :: [Module Meta] -> FilePath -> IO ()
writeHaskell = generateSources Haskell.printGraph

writeJava :: [Module Meta] -> FP.FilePath -> IO ()
writeJava = generateSources Java.printGraph

writePdl :: [Module Meta] -> FP.FilePath -> IO ()
writePdl = generateSources PDL.printGraph

writeScala :: [Module Meta] -> FP.FilePath -> IO ()
writeScala = generateSources Scala.printGraph
