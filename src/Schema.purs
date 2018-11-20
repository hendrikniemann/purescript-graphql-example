module Schema (schema) where

import Prelude

import Context (Context)
import GraphQL.Type as GraphQL
import Schema.Mutation (mutationType)
import Schema.Query (queryType)

schema :: GraphQL.Schema Context Unit
schema = GraphQL.schema queryType $ pure mutationType
