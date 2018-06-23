module Data exposing (..)

import Array exposing (Array)


type alias Request =
    { normal : Maybe NormalRequest
    }


type alias NormalRequest =
    { params : NormalParams
    , curve : Maybe Int
    , pdf : Maybe Float
    , cdf : Maybe Float
    , quantile : Maybe Float
    , sample : Maybe Int
    }


type alias NormalParams =
    { mu : Float, sigma : Float }


type alias Response =
    { normal : Maybe NormalResponse
    }


type alias NormalResponse =
    { params : NormalParams
    , mean : Float
    , stddev : Float
    , variance : Float
    , curve : Maybe ( Array Float, Array Float )
    , pdf : Maybe Float
    , cdf : Maybe Float
    , quantile : Maybe Float
    , sample : Maybe (Array Float)
    }


emptyNormalResponse : NormalResponse
emptyNormalResponse =
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


type Error
    = BadStatus String
    | BadPayload String
    | BadRequest String
