module Data.Json.Binomial exposing (decoder)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required, optional)
import Data
import Data.Json.Decode exposing (decodePairOfIntFloatArrays, decodeIntArray)


decoder : Decode.Decoder Data.BinomialResponse
decoder =
    decode Data.BinomialResponse
        |> required "Params" binomialParamsDecoder
        |> required "Mean" Decode.float
        |> required "StdDev" Decode.float
        |> required "Variance" Decode.float
        |> required "IsNormalApproximationApplicable" Decode.bool
        |> optional "Curve" (Decode.nullable decodePairOfIntFloatArrays) Nothing
        |> optional "Pmf" (Decode.nullable Decode.float) Nothing
        |> optional "Cdf" (Decode.nullable Decode.float) Nothing
        |> optional "Sample" (Decode.nullable decodeIntArray) Nothing


binomialParamsDecoder : Decode.Decoder Data.BinomialParams
binomialParamsDecoder =
    decode Data.BinomialParams
        |> required "NumberOfTrials" Decode.int
        |> required "P" Decode.float
