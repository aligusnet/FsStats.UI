module Data.Students exposing (..)

import Array exposing (Array)


type alias Request =
    { params : Params
    , curve : Maybe Int
    , pdf : Maybe Float
    , cdf : Maybe Float
    }


type alias Response =
    { params : Params
    , mean : Float
    , stddev : Float
    , variance : Float
    , curve : Maybe ( Array Float, Array Float )
    , pdf : Maybe Float
    , cdf : Maybe Float
    }


type alias Params =
    { nu : Float }


emptyResponse : Response
emptyResponse =
    { params = { nu = 0.0 }
    , mean = 0.0
    , stddev = 1.0
    , variance = 1.0
    , curve = Nothing
    , pdf = Nothing
    , cdf = Nothing
    }
