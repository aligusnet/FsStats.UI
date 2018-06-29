module Data.Hypothesis exposing (..)


type alias Request =
    { oneSampleZTest : Maybe OneSampleMeanTest
    , oneSampleTTest : Maybe OneSampleMeanTest
    }


type alias Response =
    { oneSampleZTest : Maybe OneSampleMeanTestResult
    , oneSampleTTest : Maybe OneSampleMeanTestResult
    }


type alias OneSampleMeanTest =
    { trueMean : Float
    , stdDev : Float
    , sampleMean : Float
    , sampleSize : Int
    , testType : String
    }


type alias OneSampleMeanTestResult =
    { pValue : Float
    , score : Float
    , rejectedAtSignificanceLevel001 : Bool
    , rejectedAtSignificanceLevel005 : Bool
    , rejectedAtSignificanceLevel010 : Bool
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
