module Data.Json.Bernoulli exposing (decoder)

import Json.Decode as Decode exposing (succeed)
import Json.Decode.Pipeline exposing (required, optional)
import Data.Bernoulli exposing (Params, Response)
import Data.Json.Decode exposing (decodeIntArray)


decoder : Decode.Decoder Response
decoder =
    succeed Response
        |> required "Params" paramsDecoder
        |> required "Mean" Decode.float
        |> required "StdDev" Decode.float
        |> required "Variance" Decode.float
        |> optional "Pmf" (Decode.nullable Decode.float) Nothing
        |> optional "Cdf" (Decode.nullable Decode.float) Nothing
        |> optional "Sample" (Decode.nullable decodeIntArray) Nothing


paramsDecoder : Decode.Decoder Params
paramsDecoder =
    succeed Params
        |> required "P" Decode.float
