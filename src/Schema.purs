module Schema (schema) where

import Prelude

import Data.Maybe (Maybe(..))
import Effect.Aff (Aff, Milliseconds(..), delay)
import GraphQL.Type as GraphQL

schema :: GraphQL.Schema Unit Unit
schema = GraphQL.schema queryType mutationType

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
    , userFromDraft:
        GraphQL.field
          (GraphQL.nonNull userType)
          Nothing
          { draft: GraphQL.argument (GraphQL.nonNull userDraftType) Nothing }
          resolveUserFromDraft
    }
      where
        resolveSquare :: Unit -> { value :: Maybe Int } -> Unit -> Aff Int
        resolveSquare _ { value } _ = pure $ case value of
            Just x -> x * x
            Nothing -> 0
        resolveUser :: Unit -> { id :: String } -> Unit -> Aff User
        resolveUser _ { id } _=
          pure { id, email: "me@example.com", name: "John Doe", gender: pure Male }
        resolveUserFromDraft :: Unit -> { draft :: UserDraft } -> Unit -> Aff User
        resolveUserFromDraft _ { draft: { gender, name, email } } _ =
          pure { id: "1", gender, name, email }

type User =
    { id :: String
    , email :: String
    , name :: String
    , gender :: Maybe Gender
    }

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
    , gender:
        GraphQL.field'
          genderType
          (Just (
            "The gender of the user or `null` if the user chose not to " <>
            "share their gender with the service."
          ))
          \{ gender } _ -> pure gender
    }

type UserDraft = { email :: String, name :: String, gender :: Maybe Gender }

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
    , gender:
        GraphQL.inputField
          genderType
          (Just "The gender of the user of null if they prefer not to say.")
    }

data Gender
  = Male
  | Female
  | NonBinary

genderType :: GraphQL.EnumType (Maybe Gender)
genderType =
  GraphQL.enumType
    "Gender"
    (Just "The gender of a user as reported by the user.")
    [ GraphQL.enumValue
        "MALE"
        (Just "Identifies as male.")
        Male
    , GraphQL.enumValue
        "FEMALE"
        (Just "Identifies as female.")
        Female
    , GraphQL.enumValue
        "NON_BINARY"
        (Just "Identifies neither as male nor as female.")
        NonBinary
    ]
