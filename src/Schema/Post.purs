module Schema.Post where

import Prelude

import Context (Context)
import Data.Maybe (Maybe(..))
import GraphQL.Type as GraphQL
import Store (Post, PostDraft)

postDraftType :: GraphQL.InputObjectType (Maybe PostDraft)
postDraftType =
  GraphQL.inputObjectType
    "PostDraft"
    (Just "A client side version of a post.")
    { title:
        GraphQL.inputField
          (GraphQL.nonNull GraphQL.string)
          (Just "The title for this post.")
    , content:
        GraphQL.inputField
          (GraphQL.nonNull GraphQL.string)
          (Just "The context for this post.")
    }

postType :: GraphQL.ObjectType Context (Maybe Post)
postType =
  GraphQL.objectType
    "Post"
    (Just "A blog post that is persisted in the database.")
    { id:
        GraphQL.field'
          (GraphQL.nonNull GraphQL.id)
          (Just "A unique id for this blog post.")
          (\parent _ -> pure parent.id)
    , title:
        GraphQL.field'
          (GraphQL.nonNull GraphQL.string)
          (Just "The title of this blog post.")
          (\parent _ -> pure parent.title)
    , content:
        GraphQL.field'
          (GraphQL.nonNull GraphQL.string)
          (Just "The title of this blog post.")
          (\parent _ -> pure parent.content)
    }

data PostAction
  = SetTitle { title :: String }
  | SetContent { content :: String }

type PostActionObject =
  { setTitle :: Maybe { title :: String }
  , setContent :: Maybe { content :: String }
  }

updateWithPostAction :: Post -> PostAction -> Post
updateWithPostAction post (SetTitle { title }) = post { title = title }
updateWithPostAction post (SetContent { content }) = post { content = content }

toPostAction :: PostActionObject -> Maybe PostAction
toPostAction { setTitle: Just arg, setContent: Nothing } = Just (SetTitle arg)
toPostAction { setTitle: Nothing, setContent: Just arg } = Just (SetContent arg)
toPostAction _ = Nothing

postActionType :: GraphQL.InputObjectType (Maybe PostActionObject)
postActionType =
  GraphQL.inputObjectType
    "PostAction"
    (Just "Holds all possible actions available on a post.")
    { setTitle:
        GraphQL.inputField
          postSetTitleType
          (Just "Set the title of a post to the specified value.")
    , setContent:
        GraphQL.inputField
          postSetContentType
          (Just "Set the content of a post to the specified value.")
    }

postSetTitleType :: GraphQL.InputObjectType (Maybe { title :: String })
postSetTitleType =
  GraphQL.inputObjectType
    "PostSetTitle"
    (Just "Payload for setting the title to a specified value.")
    { title:
        GraphQL.inputField
          (GraphQL.nonNull GraphQL.string)
          (Just "Value for the new title.")
    }

postSetContentType :: GraphQL.InputObjectType (Maybe { content :: String })
postSetContentType =
  GraphQL.inputObjectType
    "PostSetContent"
    (Just "Payload for setting the content to a specified value.")
    { content:
        GraphQL.inputField
          (GraphQL.nonNull GraphQL.string)
          (Just "Value for the new content.")
    }
