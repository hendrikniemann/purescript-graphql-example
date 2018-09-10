module Schema (schema) where

import Prelude

import GraphQL.Type as GraphQL
import Data.Maybe (Maybe(..))
import Effect.Aff (Aff, Milliseconds(..), delay)

schema :: GraphQL.Schema Unit Unit
schema = GraphQL.schema queryType Nothing

queryType :: GraphQL.ObjectType Unit (Maybe Unit)
queryType =
  GraphQL.objectType
    "Query"
    (Just "The main query type")
    { hello:
        GraphQL.field'
          (GraphQL.nonNull GraphQL.string)
          (Just "A simple async Hello World query")
          \_ _-> do
            delay $ Milliseconds 1000.0
            pure "Hello World"
    , square:
        GraphQL.field
          (GraphQL.nonNull GraphQL.int)
          (Just "Calculate the square of an int")
          { value: GraphQL.argument GraphQL.int Nothing }
          resolveSquare
    , user:
        GraphQL.field
          (GraphQL.nonNull userType)
          Nothing
          { id: GraphQL.argument (GraphQL.nonNull GraphQL.id) Nothing }
          resolveUser
    }
      where
        resolveSquare :: Unit -> { value :: Maybe Int } -> Unit -> Aff Int
        resolveSquare _ { value } _ = pure $ case value of
            Just x -> x * x
            Nothing -> 0
        resolveUser :: Unit -> { id :: String } -> Unit -> Aff User
        resolveUser _ { id } _= pure { id, email: "me@example.com", name: "John Doe" }

type User = { id :: String, email :: String, name :: String }

userType :: GraphQL.ObjectType Unit (Maybe User)
userType =
  GraphQL.objectType
    "User"
    (Just "A type for a user.")
    { id:
        GraphQL.field'
          (GraphQL.nonNull GraphQL.id)
          (Just "A unique id to identify this user accross the system")
          \{ id } _ -> pure id
    , email:
        GraphQL.field'
          (GraphQL.nonNull GraphQL.string)
          (Just "The email of the user.")
          \{ email } _ -> pure email
    , name:
        GraphQL.field'
          (GraphQL.nonNull GraphQL.string)
          (Just "The name of the user.")
          \{ name } _ -> pure name
    }

type UserDraft = { email :: String, name :: String }

userDraftType :: GraphQL.InputObjectType (Maybe UserDraft)
userDraftType =
  GraphQL.inputObjectType
    "UserDraft"
    (Just "A draft user type.") 
    { email:
        GraphQL.inputField
          (GraphQL.nonNull GraphQL.string)
          (Just "An email for this draft user.")
    , name:
        GraphQL.inputField
          (GraphQL.nonNull GraphQL.string)
          (Just "The name for the draft user.")
    }
