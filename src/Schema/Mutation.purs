module Schema.Mutation where

import Prelude

import Context (Context)
import Data.Maybe (Maybe(..))
import GraphQL.Type as GraphQL
import Schema.Post (postActionType, postDraftType, postType)
import Store (insertPost, readPost, removePost)

mutationType :: GraphQL.ObjectType Context (Maybe Unit)
mutationType =
  GraphQL.objectType
    "Mutation"
    (Just "The entry mutation type.")
    { createPost:
        GraphQL.field
          postType
          (Just "Create a new blog post using a draft post object.")
          { draft:
              GraphQL.argument
                (GraphQL.nonNull postDraftType)
                (Just "The draft version of the post that should be created.")
          }
          \_ { draft } ctx -> insertPost draft ctx.store
    , removePost:
        GraphQL.field
          (GraphQL.nonNull GraphQL.boolean)
          (Just "Remove a blog post.")
          { id:
              GraphQL.argument
                (GraphQL.nonNull GraphQL.id)
                (Just "The ID of the post that should be deleted.")
          }
          \_ { id } ctx -> do
            post <- readPost id ctx.store
            case post of
              Nothing -> pure false
              Just _ -> removePost id ctx.store <#> const true
    , updatePost:
        GraphQL.field
          postType
          (Just "Update a post by it's ID.")
          { id:
              GraphQL.argument
                (GraphQL.nonNull GraphQL.id)
                (Just "The ID of the post that should be updated.")
          , actions:
              GraphQL.argument
                (GraphQL.nonNull
                  $ GraphQL.list
                  $ GraphQL.nonNull
                  $ postActionType)
                (Just "List of actions that should be run on this post.")
          }
          -- TODO: Implement the actual update!
          \_ { id, actions } ctx -> readPost id ctx.store
    }
