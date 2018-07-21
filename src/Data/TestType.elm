module Data.TestType exposing (..)


type TestType
    = LowerTailed
    | UpperTailed
    | TwoTailed


toString : TestType -> String
toString t =
    case t of
        LowerTailed ->
            "LowerTailed"

        UpperTailed ->
            "UpperTailed"

        TwoTailed ->
            "TwoTailed"
