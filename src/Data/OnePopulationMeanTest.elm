module Data.OnePopulationMeanTest exposing (..)


type alias Request =
    { params : Params
    , testType : String
    }


type alias Response =
    { score : Float
    , zTest : Float
    , tTest : Float
    }


type alias Params =
    { populationMean : Float
    , sampleMean : Float
    , sampleSize : Int
    , stdDev : Float
    }


emptyResponse : Response
emptyResponse =
    { score = 0.0
    , zTest = 0.0
    , tTest = 0.0
    }
