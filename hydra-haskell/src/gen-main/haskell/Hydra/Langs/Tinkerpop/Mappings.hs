-- | A model for property graph mapping specifications

module Hydra.Langs.Tinkerpop.Mappings where

import qualified Hydra.Core as Core
import qualified Hydra.Langs.Tinkerpop.V3 as V3
import Data.List
import Data.Map
import Data.Set

-- | A mapping specification producing edges of a specified label.
data EdgeSpec = 
  EdgeSpec {
    -- | The label of the target edges, which must conform to the edge type associated with that label.
    edgeSpecLabel :: V3.EdgeLabel,
    -- | A specification of the id of each target edge
    edgeSpecId :: ValueSpec,
    -- | A specification of the out-vertex reference of each target edge
    edgeSpecOut :: ValueSpec,
    -- | A specification of the in-vertex reference of each target edge
    edgeSpecIn :: ValueSpec,
    -- | Zero or more property specifications for each target edge
    edgeSpecProperties :: PropertySpec}
  deriving (Eq, Ord, Read, Show)

_EdgeSpec = (Core.Name "hydra/langs/tinkerpop/mappings.EdgeSpec")

_EdgeSpec_label = (Core.FieldName "label")

_EdgeSpec_id = (Core.FieldName "id")

_EdgeSpec_out = (Core.FieldName "out")

_EdgeSpec_in = (Core.FieldName "in")

_EdgeSpec_properties = (Core.FieldName "properties")

-- | A mapping specification producing properties of a specified key, and values of the appropriate type.
data PropertySpec = 
  PropertySpec {
    -- | The key of the target properties
    propertySpecKey :: V3.PropertyKey,
    -- | A specification of the value of each target property, which must conform to the type associated with the property key
    propertySpecValue :: ValueSpec}
  deriving (Eq, Ord, Read, Show)

_PropertySpec = (Core.Name "hydra/langs/tinkerpop/mappings.PropertySpec")

_PropertySpec_key = (Core.FieldName "key")

_PropertySpec_value = (Core.FieldName "value")

-- | A mapping specification producing values (usually literal values) whose type is understood in context
data ValueSpec = 
  -- | A compact path representing the function, e.g. ${}/engineInfo/model/name
  ValueSpecPattern String
  deriving (Eq, Ord, Read, Show)

_ValueSpec = (Core.Name "hydra/langs/tinkerpop/mappings.ValueSpec")

_ValueSpec_pattern = (Core.FieldName "pattern")

-- | A mapping specification producing vertices of a specified label
data VertexSpec = 
  VertexSpec {
    -- | The label of the target vertices, which must conform to the vertex type associated with that label.
    vertexSpecLabel :: V3.VertexLabel,
    -- | A specification of the id of each target vertex
    vertexSpecId :: ValueSpec,
    -- | Zero or more property specifications for each target vertex
    vertexSpecProperties :: [PropertySpec]}
  deriving (Eq, Ord, Read, Show)

_VertexSpec = (Core.Name "hydra/langs/tinkerpop/mappings.VertexSpec")

_VertexSpec_label = (Core.FieldName "label")

_VertexSpec_id = (Core.FieldName "id")

_VertexSpec_properties = (Core.FieldName "properties")