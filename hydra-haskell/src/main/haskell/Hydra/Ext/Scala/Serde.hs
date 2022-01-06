module Hydra.Ext.Scala.Serde (
  dataGraphToScalaString,
) where

import Hydra.Errors
import Hydra.Evaluation
import Hydra.Graph
import Hydra.Ext.Scala.Coder
import Hydra.Impl.Haskell.Extras
import Hydra.Util.Codetree.Print
import Hydra.Util.Codetree.Script
import qualified Hydra.Lib.Literals as Literals
import qualified Hydra.Util.Codetree.Ast as CT
import qualified Hydra.Ext.Scala.Meta as Scala

import qualified Data.Char as C
import qualified Data.List as L
import qualified Data.Maybe as Y


dataGraphToScalaString :: (Default a, Ord a, Read a, Show a) => Context a -> Graph a -> Qualified String
dataGraphToScalaString cx g = do
  pkg <- dataGraphToScalaPackage cx g
  return $ printExpr $ parenthesize $ writePkg pkg

writeDefn :: Scala.Defn -> CT.Expr
writeDefn def = case def of
  Scala.DefnDef (Scala.Defn_Def _ name tparams [params] _ body) -> spaceSep [
      cst "def", nameAndParams, cst "=", writeTerm body]
    where
      nameAndParams = noSep [writeTerm_Name name, parenList (writeTerm_Param <$> params)]

  Scala.DefnVal (Scala.Defn_Val _ [Scala.PatVar (Scala.Pat_Var (Scala.Term_Name name))] typ term) -> spaceSep [
      cst "val", nameAndType, cst "=", writeTerm term]
    where
      nameAndType = Y.maybe (cst name) (\t -> spaceSep [cst $ name ++ ":", writeType t]) typ

writeImportExportStat :: Scala.ImportExportStat -> CT.Expr
writeImportExportStat ie = case ie of
  Scala.ImportExportStatImport (Scala.Import importers) -> newlineSep (writeImporter <$> importers)
--  Scala.ImportExportStatExport exp ->

writeImporter :: Scala.Importer -> CT.Expr
writeImporter (Scala.Importer (Scala.Term_RefName (Scala.Term_Name ref)) importees) = newlineSep (write <$> importees)
  where
    write it = spaceSep [cst "import", cst (ref ++ forImportee it)]
    forImportee it = case it of
      Scala.ImporteeWildcard -> ".*"
      Scala.ImporteeName (Scala.Importee_Name (Scala.NameValue name)) -> "." ++ name

writeLit :: Scala.Lit -> CT.Expr
writeLit lit = case lit of
--  Scala.LitNull
  Scala.LitInt i -> cst $ Literals.showInt32 i
--  Scala.LitDouble Double
--  Scala.LitFloat Float
--  Scala.LitByte Integer
--  Scala.LitShort Integer
--  Scala.LitChar Integer
--  Scala.LitLong Int64
--  Scala.LitBoolean Bool
--  Scala.LitUnit
  Scala.LitString s -> cst $ Literals.showString s
--  Scala.LitSymbol sym ->
  _ -> cst $ Literals.showString $ "TODO:literal:" ++ show lit

writeName :: Scala.Name -> CT.Expr
writeName name = case name of
  Scala.NameValue s -> cst s

writePkg :: Scala.Pkg -> CT.Expr
writePkg (Scala.Pkg name _ stats) = doubleNewlineSep $ package:(writeStat <$> stats)
  where
    package = spaceSep [cst "package", writeTerm_Name name]

writeStat :: Scala.Stat -> CT.Expr
writeStat stat = case stat of
--  Scala.StatTerm Term ->
--  Scala.StatDecl Decl ->
  Scala.StatDefn def -> writeDefn def
  Scala.StatImportExport ie -> writeImportExportStat ie

writeTerm :: Scala.Term -> CT.Expr
writeTerm term = case term of
  Scala.TermLit lit -> writeLit lit
  Scala.TermRef ref -> writeTerm_Ref ref
  Scala.TermApply apply -> cst "APPLY"
  Scala.TermAssign assign -> cst "ASSIGN"
  Scala.TermTuple tuple -> cst "TUPLE"
  Scala.TermMatch match -> cst "MATCH"
  Scala.TermFunctionTerm ft -> writeTerm_FunctionTerm ft

writeTerm_FunctionTerm :: Scala.Term_FunctionTerm -> CT.Expr
writeTerm_FunctionTerm ft = case ft of
  Scala.Term_FunctionTermFunction (Scala.Term_Function params body) -> noSep [writeTerm body, parenList (writeTerm_Param <$> params)]

writeTerm_Name :: Scala.Term_Name -> CT.Expr
writeTerm_Name (Scala.Term_Name name) = cst name

writeTerm_Param :: Scala.Term_Param -> CT.Expr
writeTerm_Param (Scala.Term_Param _ name) = writeName name

writeTerm_Ref :: Scala.Term_Ref -> CT.Expr
writeTerm_Ref ref = case ref of
  Scala.Term_RefName name -> writeTerm_Name name

writeType :: Scala.Type -> CT.Expr
writeType typ = cst "TYPE"