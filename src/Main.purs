module Main where

import Prelude

import Data.Argonaut as A
import Data.Either (Either, either, note)
import GraphQL (graphql)
import Data.Maybe (Maybe)
import Effect.Console as Console
import Foreign.Object (lookup)
import HTTPure as HTTPure
import Schema (schema)

respondGraphQL :: GraphQLParams-> HTTPure.ResponseM
respondGraphQL { query, variables, operationName } =
    map A.stringify result >>= HTTPure.ok
      where
        result = graphql schema query unit variables operationName

type GraphQLParams =
  { query :: String
  , variables :: Maybe A.Json
  , operationName :: Maybe String
  }

parseBody :: String -> Either String GraphQLParams
parseBody body = do
  json <- A.jsonParser body
  object <- note "Request body must be an object." $ A.toObject json
  query <- note "No query provided." $ lookup "query" object >>= A.toString
  let variables = lookup "variables" object
  let operationName = lookup "operationName" object >>= A.toString
  pure { query, variables, operationName }

router :: HTTPure.Request -> HTTPure.ResponseM
router { body, method: HTTPure.Post } =
  either HTTPure.badRequest respondGraphQL $ parseBody body
router _ = HTTPure.notFound

main :: HTTPure.ServerM
main = HTTPure.serve 8080 router do
  Console.log $ "Server running on port 8080"
