module Data.Normal exposing (..)

import Array exposing (Array)


type alias Request =
    { params : Params
    , curve : Maybe Int
    , pdf : Maybe Float
    , cdf : Maybe Float
    , quantile : Maybe Float
    , sample : Maybe Int
    }


type alias Response =
    { params : Params
    , mean : Float
    , stddev : Float
    , variance : Float
    , curve : Maybe ( Array Float, Array Float )
    , pdf : Maybe Float
    , cdf : Maybe Float
    , quantile : Maybe Float
    , sample : Maybe (Array Float)
    }


type alias Params =
    { mu : Float, sigma : Float }


emptyResponse : Response
emptyResponse =
    { params = { mu = 0.0, sigma = 1.0 }
    , mean = 0.0
    , stddev = 1.0
    , variance = 1.0
    , curve = Nothing
    , pdf = Nothing
    , cdf = Nothing
    , quantile = Nothing
    , sample = Nothing
    }
