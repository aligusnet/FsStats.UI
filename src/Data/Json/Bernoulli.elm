module Data.Json.Bernoulli exposing (decoder)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required, optional)
import Data.Bernoulli exposing (Params, Response)
import Data.Json.Decode exposing (decodeIntArray)


decoder : Decode.Decoder Response
decoder =
    decode Response
        |> required "Params" paramsDecoder
        |> required "Mean" Decode.float
        |> required "StdDev" Decode.float
        |> required "Variance" Decode.float
        |> optional "Pmf" (Decode.nullable Decode.float) Nothing
        |> optional "Cdf" (Decode.nullable Decode.float) Nothing
        |> optional "Sample" (Decode.nullable decodeIntArray) Nothing


paramsDecoder : Decode.Decoder Params
paramsDecoder =
    decode Params
        |> required "P" Decode.float
