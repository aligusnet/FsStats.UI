module Data.Hypothesis exposing (..)


type alias Request =
    { oneSampleZTest : Maybe OneSampleMeanTest
    , oneSampleTTest : Maybe OneSampleMeanTest
    }


type alias Response =
    { oneSampleZTest : Maybe Float
    , oneSampleTTest : Maybe Float
    }


type alias OneSampleMeanTest =
    { trueMean : Float
    , stdDev : Float
    , sampleMean : Float
    , sampleSize : Int
    , testType : String
    }


testTypeLowerTailed : String
testTypeLowerTailed =
    "LowerTailed"


testTypeUpperTailed : String
testTypeUpperTailed =
    "UpperTailed"


testTypeTwoTailed : String
testTypeTwoTailed =
    "TwoTailed"


type TestType
    = LowerTailed
    | UpperTailed
    | TwoTailed


testTypeToString : TestType -> String
testTypeToString t =
    case t of
        LowerTailed ->
            "LowerTailed"

        UpperTailed ->
            "UpperTailed"

        TwoTailed ->
            "TwoTailed"


emptyResponse : Response
emptyResponse =
    { oneSampleZTest = Nothing
    , oneSampleTTest = Nothing
    }
