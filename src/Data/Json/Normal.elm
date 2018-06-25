module Data.Json.Normal exposing (decoder)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required, optional)
import Data
import Data.Json.Decode exposing (decodePairOfFloatArrays, decodeFloatArray)


decoder : Decode.Decoder Data.NormalResponse
decoder =
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


normalParamsDecoder : Decode.Decoder Data.NormalParams
normalParamsDecoder =
    decode Data.NormalParams
        |> required "Mu" Decode.float
        |> required "Sigma" Decode.float
