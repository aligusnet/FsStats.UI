module Data exposing (..)

import Data.Normal as Normal
import Data.Binomial as Binomial
import Data.Poisson as Poisson


type alias Request =
    { normal : Maybe Normal.Request
    , binomial : Maybe Binomial.Request
    , poisson : Maybe Poisson.Request
    }


emptyRequest : Request
emptyRequest =
    { normal = Nothing
    , binomial = Nothing
    , poisson = Nothing
    }


type alias Response =
    { normal : Maybe Normal.Response
    , binomial : Maybe Binomial.Response
    , poisson : Maybe Poisson.Response
    }


type Error
    = BadStatus String
    | BadPayload String
    | BadRequest String
