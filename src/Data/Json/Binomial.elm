module Data.Json.Binomial exposing (decoder)

import Json.Decode as Decode exposing (succeed)
import Json.Decode.Pipeline exposing (required, optional)
import Data.Binomial exposing (Params, Response)
import Data.Json.Decode exposing (decodePairOfIntFloatArrays, decodeIntArray)


decoder : Decode.Decoder Response
decoder =
    succeed Response
        |> required "Params" binomialParamsDecoder
        |> required "Mean" Decode.float
        |> required "StdDev" Decode.float
        |> required "Variance" Decode.float
        |> required "IsNormalApproximationApplicable" Decode.bool
        |> optional "Curve" (Decode.nullable decodePairOfIntFloatArrays) Nothing
        |> optional "Pmf" (Decode.nullable Decode.float) Nothing
        |> optional "Cdf" (Decode.nullable Decode.float) Nothing
        |> optional "Sample" (Decode.nullable decodeIntArray) Nothing


binomialParamsDecoder : Decode.Decoder Params
binomialParamsDecoder =
    succeed Params
        |> required "NumberOfTrials" Decode.int
        |> required "P" Decode.float
