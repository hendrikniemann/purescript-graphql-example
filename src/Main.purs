module Main where

import Prelude

import Data.Argonaut (class DecodeJson, Json, decodeJson, jsonParser, stringify, (.?), (.??))
import Data.Either (Either(..), either)
import Data.Maybe (Maybe)
import Effect (Effect)
import Effect.Aff (runAff_)
import Effect.Class (liftEffect)
import Effect.Console as Console
import Context (Context)
import GraphQL (graphql)
import HTTPure as HTTPure
import Schema (schema)
import Store (createStore)

newtype GraphQLParams = GraphQLParams
  { query :: String
  , variables :: Maybe Json
  , operationName :: Maybe String
  }

instance decodeJsonGraphQLParams :: DecodeJson GraphQLParams where
  decodeJson json = do
    obj <- decodeJson json
    query <- obj .? "query"
    variables <- obj .?? "variables"
    operationName <- obj .?? "operationName"
    pure $ GraphQLParams { query, variables, operationName }

createRouter :: Context -> HTTPure.Request -> HTTPure.ResponseM
createRouter context { body, method: HTTPure.Post, path: [ "graphql" ] } =
  case jsonParser body >>= decodeJson of
    Left error -> HTTPure.badRequest error
    Right (GraphQLParams { query, variables, operationName }) -> do
      result <- graphql schema query unit context variables operationName
      HTTPure.ok $ stringify result
createRouter _ _ = HTTPure.notFound

main :: Effect Unit
main = runAff_ (either (show >>> Console.error) pure) do
  store <- createStore
  let router = createRouter { store }
  liftEffect $ HTTPure.serve 8080 router $ Console.log "Running server..."
