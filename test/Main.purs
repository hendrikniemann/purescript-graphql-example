module Test.Main where

import Prelude

import Data.Maybe (Maybe(..))
import Effect (Effect)
import Store (createStore, insertPost, readPost, readPosts)
import Test.Spec (describe, it)
import Test.Spec.Assertions (fail, shouldEqual)
import Test.Spec.Reporter (consoleReporter)
import Test.Spec.Runner (run)

main :: Effect Unit
main = run [consoleReporter] $
  describe "Store" do
    describe "createStore and readPosts" $
      it "initialise an read an empty store" do
        store <- createStore
        posts <- readPosts store
        posts `shouldEqual` []
    
    describe "insertPost" $
      it "should insert a single post into the store" do
        store <- createStore
        let draft = { title: "Hello", content: "world" }
        insertResult <- insertPost draft store
        case insertResult of
          Nothing ->
            fail "Insert post should return Just post but returned Nothing"
          Just newPost -> do
            newPost.title `shouldEqual` draft.title
            newPost.content `shouldEqual` draft.content
            posts <- readPosts store
            posts `shouldEqual` [newPost]

    describe "readPost" do
      it "should find a single post by it's id" do
        store <- createStore
        insertResult <- insertPost { title: "Hello", content: "world" } store
        case insertResult of
          Nothing ->
            fail "Insert post should return Just post but returned Nothing"
          Just newPost -> do
            receivedPost <- readPost newPost.id store
            receivedPost `shouldEqual` Just newPost
      
      it "should return Nothing if an id cannot be found in the store" do
        store <- createStore
        receivedPost <- readPost "asdf" store
        receivedPost `shouldEqual` Nothing
