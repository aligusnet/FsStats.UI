module Data.Bernoulli exposing (..)

import Array exposing (Array)


type alias Request =
    { params : Params
    , pmf : Maybe Int
    , cdf : Maybe Int
    , sample : Maybe Int
    }


type alias Params =
    { p : Float }


type alias Response =
    { params : Params
    , mean : Float
    , stddev : Float
    , variance : Float
    , pmf : Maybe Float
    , cdf : Maybe Float
    , sample : Maybe (Array Int)
    }


emptyResponse : Response
emptyResponse =
    { params = { p = 0.0 }
    , mean = 0.0
    , stddev = 0.0
    , variance = 0.0
    , pmf = Nothing
    , cdf = Nothing
    , sample = Nothing
    }
