module Data.Binomial exposing (..)

import Array exposing (Array)


type alias Request =
    { params : Params
    , curve : Bool
    , pmf : Maybe Int
    , cdf : Maybe Int
    , sample : Maybe Int
    }


type alias Params =
    { numberOfTrials : Int, p : Float }


type alias Response =
    { params : Params
    , mean : Float
    , stddev : Float
    , variance : Float
    , isNormalApproximationApplicable : Bool
    , curve : Maybe ( Array Int, Array Float )
    , pmf : Maybe Float
    , cdf : Maybe Float
    , sample : Maybe (Array Int)
    }


emptyResponse : Response
emptyResponse =
    { params = { numberOfTrials = 0, p = 0.0 }
    , mean = 0.0
    , stddev = 0.0
    , variance = 0.0
    , isNormalApproximationApplicable = False
    , curve = Nothing
    , pmf = Nothing
    , cdf = Nothing
    , sample = Nothing
    }
