module Data.Json.Hypothesis exposing (decoder)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, optional)
import Data.Hypothesis exposing (Response)


decoder : Decode.Decoder Response
decoder =
    decode Response
        |> optional "OneSampleZTest" (Decode.nullable Decode.float) Nothing
        |> optional "OneSampleTTest" (Decode.nullable Decode.float) Nothing
