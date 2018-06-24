module Data exposing (..)

import Array exposing (Array)


type alias Request =
    { normal : Maybe NormalRequest
    , binomial : Maybe BinomialRequest
    }


emptyRequest : Request
emptyRequest =
    { normal = Nothing
    , binomial = Nothing
    }


type alias NormalRequest =
    { params : NormalParams
    , curve : Maybe Int
    , pdf : Maybe Float
    , cdf : Maybe Float
    , quantile : Maybe Float
    , sample : Maybe Int
    }


type alias BinomialRequest =
    { params : BinomialParams
    , curve : Maybe Int
    , pmf : Maybe Int
    , cdf : Maybe Int
    , sample : Maybe Int
    }


type alias NormalParams =
    { mu : Float, sigma : Float }


type alias BinomialParams =
    { numberOfTrials : Int, p : Float }


type alias Response =
    { normal : Maybe NormalResponse
    , binomial : Maybe BinomialResponse
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


type alias BinomialResponse =
    { params : BinomialParams
    , mean : Float
    , stddev : Float
    , variance : Float
    , isNormalApproximationApplicable : Bool
    , curve : Maybe ( Array Int, Array Float )
    , pmf : Maybe Float
    , cdf : Maybe Float
    , sample : Maybe (Array Int)
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


emptyBinomialResponse : BinomialResponse
emptyBinomialResponse =
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


type Error
    = BadStatus String
    | BadPayload String
    | BadRequest String
