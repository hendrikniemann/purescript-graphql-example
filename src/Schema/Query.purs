module Schema.Query (queryType) where

import Prelude

import Context (Context)
import Data.Maybe (Maybe(..))
import GraphQL.Type as GraphQL
import Schema.Post (postType)
import Store (readPost, readPosts)

queryType :: GraphQL.ObjectType Context (Maybe Unit)
queryType =
  GraphQL.objectType
    "Query"
    (Just "The main query type")
    { post:
        GraphQL.field
          postType
          (Just "Query a single post by its ID.")
          { id:
              GraphQL.argument
                (GraphQL.nonNull GraphQL.id)
                (Just "The unique id that references this post.")
          }
          \_ { id } ctx -> readPost id ctx.store
    , posts:
        GraphQL.field'
          (GraphQL.nonNull $ GraphQL.list $ GraphQL.nonNull postType)
          (Just "A simple async Hello World query")
          \_ { store } -> readPosts store
    }