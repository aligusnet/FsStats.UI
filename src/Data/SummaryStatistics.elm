module Data.SummaryStatistics exposing (..)

import Array exposing (Array)


type alias Request =
    { params : Array Float
    , percentile : Maybe Float
    , correlation : Maybe (Array Float)
    }


type alias Response =
    { params : Array Float
    , mean : Float
    , stddev : Float
    , variance : Float
    , skewness : Float
    , kurtosis : Float
    , minimum : Float
    , q2 : Float
    , median : Float
    , q4 : Float
    , maximum : Float
    , iqr : Float
    , size : Int
    , percentile : Maybe Float
    , correlation : Maybe Float
    }


emptyResponse : Response
emptyResponse =
    { params = Array.empty
    , mean = 0.0
    , stddev = 1.0
    , variance = 1.0
    , skewness = 0.0
    , kurtosis = 0.0
    , minimum = 0.0
    , q2 = 0.0
    , median = 0.0
    , q4 = 0.0
    , maximum = 0.0
    , iqr = 0.0
    , size = 0
    , percentile = Nothing
    , correlation = Nothing
    }
