module Context (Context) where

import Store (Store)

-- | The context type contains all configuration and state that the resolvers
-- | need to execute a request. In our context we include the store that will
-- | act as a database connection.
type Context = { store :: Store }
