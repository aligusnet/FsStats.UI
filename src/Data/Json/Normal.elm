module Data.Json.Normal exposing (decoder)

import Json.Decode as Decode exposing (succeed)
import Json.Decode.Pipeline exposing (required, optional)
import Data.Normal exposing (Params, Response)
import Data.Json.Decode exposing (decodePairOfFloatArrays, decodeFloatArray)


decoder : Decode.Decoder Response
decoder =
    succeed Response
        |> required "Params" normalParamsDecoder
        |> required "Mean" Decode.float
        |> required "StdDev" Decode.float
        |> required "Variance" Decode.float
        |> optional "Curve" (Decode.nullable decodePairOfFloatArrays) Nothing
        |> optional "Pdf" (Decode.nullable Decode.float) Nothing
        |> optional "Cdf" (Decode.nullable Decode.float) Nothing
        |> optional "Quantile" (Decode.nullable Decode.float) Nothing
        |> optional "Sample" (Decode.nullable decodeFloatArray) Nothing


normalParamsDecoder : Decode.Decoder Params
normalParamsDecoder =
    succeed Params
        |> required "Mu" Decode.float
        |> required "Sigma" Decode.float
