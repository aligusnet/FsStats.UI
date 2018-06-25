module Data.Json.Students exposing (decoder)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required, optional)
import Data.Students exposing (Params, Response)
import Data.Json.Decode exposing (decodePairOfFloatArrays)


decoder : Decode.Decoder Response
decoder =
    decode Response
        |> required "Params" paramsDecoder
        |> required "Mean" Decode.float
        |> required "StdDev" Decode.float
        |> required "Variance" Decode.float
        |> optional "Curve" (Decode.nullable decodePairOfFloatArrays) Nothing
        |> optional "Pdf" (Decode.nullable Decode.float) Nothing
        |> optional "Cdf" (Decode.nullable Decode.float) Nothing


paramsDecoder : Decode.Decoder Params
paramsDecoder =
    decode Params
        |> required "Nu" Decode.float
