module Data exposing (..)

import Data.Normal as Normal
import Data.Binomial as Binomial
import Data.Poisson as Poisson
import Data.Students as Students


type alias Request =
    { normal : Maybe Normal.Request
    , binomial : Maybe Binomial.Request
    , poisson : Maybe Poisson.Request
    , students : Maybe Students.Request
    }


emptyRequest : Request
emptyRequest =
    { normal = Nothing
    , binomial = Nothing
    , poisson = Nothing
    , students = Nothing
    }


type alias Response =
    { normal : Maybe Normal.Response
    , binomial : Maybe Binomial.Response
    , poisson : Maybe Poisson.Response
    , students : Maybe Students.Response
    }


type Error
    = BadStatus String
    | BadPayload String
    | BadRequest String
