module Data.Poisson exposing (..)

import Array exposing (Array)


type alias Request =
    { params : Params
    , curve : Bool
    , pmf : Maybe Int
    , cdf : Maybe Int
    , sample : Maybe Int
    }


type alias Params =
    { mu : Float }


type alias Response =
    { params : Params
    , mean : Float
    , stddev : Float
    , variance : Float
    , curve : Maybe ( Array Int, Array Float )
    , pmf : Maybe Float
    , cdf : Maybe Float
    , sample : Maybe (Array Int)
    }


emptyResponse : Response
emptyResponse =
    { params = { mu = 0.0 }
    , mean = 0.0
    , stddev = 0.0
    , variance = 0.0
    , curve = Nothing
    , pmf = Nothing
    , cdf = Nothing
    , sample = Nothing
    }
