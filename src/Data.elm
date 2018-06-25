module Data exposing (..)

import Data.Normal as Normal
import Data.Binomial as Binomial


type alias Request =
    { normal : Maybe Normal.Request
    , binomial : Maybe Binomial.Request
    }


emptyRequest : Request
emptyRequest =
    { normal = Nothing
    , binomial = Nothing
    }


type alias Response =
    { normal : Maybe Normal.Response
    , binomial : Maybe Binomial.Response
    }


type Error
    = BadStatus String
    | BadPayload String
    | BadRequest String
