module Store where

import Prelude

import Data.Array (filter, (:))
import Data.Foldable (class Foldable, find)
import Data.Maybe (Maybe(..))
import Data.UUID (genUUID)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Ref as Ref

type Post = { id :: String, title :: String, content :: String }

type PostDraft = { title :: String, content :: String }

type Store = { posts :: Ref.Ref (Array Post) }

createStore :: Aff Store
createStore = do
  posts <- liftEffect $ Ref.new []
  pure { posts }

findById :: forall r f. Foldable f
  => String -> f { id :: String | r } -> Maybe { id :: String | r }
findById id = find $ _.id >>> (_ == id) 

readPosts :: Store -> Aff (Array Post)
readPosts store = liftEffect $ Ref.read store.posts

readPost :: String -> Store -> Aff (Maybe Post)
readPost id = readPosts >>> map (findById id)

insertPost :: PostDraft -> Store -> Aff (Maybe Post)
insertPost { title, content } store = liftEffect do
  id <- show <$> genUUID
  let post = { id, title, content }
  _ <- Ref.modify (post:_) store.posts
  pure $ Just post

removePost :: String -> Store -> Aff Unit
removePost id store =
  liftEffect $ Ref.modify_ (filter \post -> post.id /= id) store.posts

updatePost :: Post -> Store -> Aff (Maybe Post)
updatePost newPost store = do
  liftEffect $ Ref.modify_ update store.posts
  readPost newPost.id store
    where
      update posts = posts <#> \post ->
        if post.id == newPost.id then newPost else post
