let upstream =
      https://github.com/purescript/package-sets/releases/download/psc-0.13.3-20190831/packages.dhall sha256:852cd4b9e463258baf4e253e8524bcfe019124769472ca50b316fe93217c3a47

let overrides = {=}

let additions =
    { graphql =
        { dependencies =
            [ "aff"
            , "aff-promise"
            , "argonaut-codecs"
            , "argonaut-core"
            , "foldable-traversable"
            , "nullable"
            , "numbers"
            , "prelude"
            , "psci-support"
            , "record"
            , "spec"
            , "string-parsers"
            ]
        , repo = "https://github.com/hendrikniemann/purescript-graphql.git"
        , version = "v1.0.1"
        }
    , uuid =
        { dependencies =
            [ "effect"
            ]
        , repo = "https://github.com/spicydonuts/purescript-uuid"
        , version = "v6.0.0"
        }
    }

in  upstream // overrides // additions
