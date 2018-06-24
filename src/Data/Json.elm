module Data.Json exposing (decodeResponse)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required, optional)
import Array exposing (Array)
import Data


decodeResponse : String -> Result String Data.Response
decodeResponse value =
    Decode.decodeString responseDecoder value


responseDecoder : Decode.Decoder Data.Response
responseDecoder =
    decode Data.Response
        |> optional "Normal" (Decode.nullable normalResponseDecoder) Nothing
        |> optional "Binomial" (Decode.nullable binomialResponseDecoder) Nothing


normalResponseDecoder : Decode.Decoder Data.NormalResponse
normalResponseDecoder =
    decode Data.NormalResponse
        |> required "Params" normalParamsDecoder
        |> required "Mean" Decode.float
        |> required "StdDev" Decode.float
        |> required "Variance" Decode.float
        |> optional "Curve" (Decode.nullable decodePairOfFloatArrays) Nothing
        |> optional "Pdf" (Decode.nullable Decode.float) Nothing
        |> optional "Cdf" (Decode.nullable Decode.float) Nothing
        |> optional "Quantile" (Decode.nullable Decode.float) Nothing
        |> optional "Sample" (Decode.nullable decodeFloatArray) Nothing


binomialParamsDecoder : Decode.Decoder Data.BinomialParams
binomialParamsDecoder =
    decode Data.BinomialParams
        |> required "NumberOfTrials" Decode.int
        |> required "P" Decode.float


binomialResponseDecoder : Decode.Decoder Data.BinomialResponse
binomialResponseDecoder =
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


normalParamsDecoder : Decode.Decoder Data.NormalParams
normalParamsDecoder =
    decode Data.NormalParams
        |> required "Mu" Decode.float
        |> required "Sigma" Decode.float


decodePairOfFloatArrays : Decode.Decoder ( Array Float, Array Float )
decodePairOfFloatArrays =
    Decode.map2 (,) (Decode.index 0 decodeFloatArray) (Decode.index 1 decodeFloatArray)


decodePairOfIntFloatArrays : Decode.Decoder ( Array Int, Array Float )
decodePairOfIntFloatArrays =
    Decode.map2 (,) (Decode.index 0 decodeIntArray) (Decode.index 1 decodeFloatArray)


decodeFloatArray : Decode.Decoder (Array Float)
decodeFloatArray =
    Decode.array Decode.float


decodeIntArray : Decode.Decoder (Array Int)
decodeIntArray =
    Decode.array Decode.int
