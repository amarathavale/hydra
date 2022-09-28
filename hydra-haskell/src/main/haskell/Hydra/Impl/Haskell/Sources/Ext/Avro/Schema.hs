{-# LANGUAGE OverloadedStrings #-}

module Hydra.Impl.Haskell.Sources.Ext.Avro.Schema where

import Hydra.Impl.Haskell.Sources.Core

import Hydra.Core
import Hydra.Graph
import Hydra.Impl.Haskell.Dsl.Types as Types
import Hydra.Impl.Haskell.Dsl.Standard
import Hydra.Impl.Haskell.Sources.Ext.Rdf.Syntax

import Hydra.Impl.Haskell.Sources.Ext.Json.Model


avroSchemaModule :: Module Meta
avroSchemaModule = Module ns elements [jsonModelModule] $
    Just ("A model for Avro schemas. Based on the Avro 1.11.1 specification:\n" ++
      "  https://avro.apache.org/docs/1.11.1/specification)")
  where
    ns = Namespace "hydra/ext/avro/schema"
    def = datatype ns
    avro = nsref ns
    json = nsref $ moduleNamespace jsonModelModule

    elements = [
      def "Array" $
        record [
          "items">: avro "Schema"],

      def "Enum" $
        record [
          "symbols">:
            doc ("a JSON array, listing symbols, as JSON strings. All symbols in an enum must be unique; " ++
              "duplicates are prohibited. Every symbol must match the regular expression [A-Za-z_][A-Za-z0-9_]* " ++
              "(the same requirement as for names)") $
            list string,
          "default">:
            doc ("A default value for this enumeration, used during resolution when the reader encounters " ++
              "a symbol from the writer that isn’t defined in the reader’s schema. " ++
              "The value provided here must be a JSON string that’s a member of the symbols array") $
            optional string],

      def "Field" $
        record [
          "name">:
            doc "a JSON string providing the name of the field"
            string,
          "doc">:
            doc "a JSON string describing this field for users" $
            optional string,
          "type">:
            doc "a schema" $
            avro "Schema",
          "default">:
            doc "default value for this field, only used when reading instances that lack the field for schema evolution purposes" $
            optional $ json "Value",
          "order">:
            doc "specifies how this field impacts sort ordering of this record" $
            optional $ avro "Order",
          "aliases">:
            doc "a JSON array of strings, providing alternate names for this field" $
            optional $ list string],

      def "Fixed" $
        record [
          "size">:
            doc "an integer, specifying the number of bytes per value"
            int32],

      def "Map" $
        record [
          "values">: avro "Schema"],

      def "Named" $
        record [
          "name">:
            doc "a string naming this schema"
            string,
          "namespace">:
            doc "a string that qualifies the name" $
            optional string,
          "aliases">:
            doc "a JSON array of strings, providing alternate names for this schema" $
            optional $ list string,
          "doc">:
            doc "a JSON string providing documentation to the user of this schema" $
            optional string,
          "type">:
            union [
              "enum">: avro "Enum",
              "fixed">: avro "Fixed",
              "record">: avro "Record"]],

      def "Order" $
        enum ["ascending", "descending", "ignore"],

      def "Primitive" $
        union [
          "null">:
            doc "no value" unit,
          "boolean">:
            doc "A binary value" unit,
          "int">:
            doc "32-bit signed integer" unit,
          "long">:
            doc "64-bit signed integer" unit,
          "float">:
            doc "single precision (32-bit) IEEE 754 floating-point number" unit,
          "double">:
            doc "double precision (64-bit) IEEE 754 floating-point number" unit,
          "bytes">:
            doc "sequence of 8-bit unsigned bytes" unit,
          "string">:
            doc "unicode character sequence" unit],

      def "Record" $
        record [
          "fields">:
            doc "a JSON array, listing fields" $
            list $ avro "Field"],

      def "Schema" $
        union [
          "array">: avro "Array",
          "map">: avro "Map",
          "named">: avro "Named",
          "primitive">: avro "Primitive",
          "union">: avro "Union"
        ],

      def "Union" $
        list $ avro "Schema"]
