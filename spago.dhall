{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name =
    "graphql-example"
, dependencies =
    [ "argonaut-codecs"
    , "argonaut-core"
    , "console"
    , "effect"
    , "foreign-object"
    , "graphql"
    , "httpure"
    , "prelude"
    , "psci-support"
    , "refs"
    , "spec"
    , "uuid"
    ]
, packages =
    ./packages.dhall
, sources =
    [ "src/**/*.purs", "test/**/*.purs" ]
}
