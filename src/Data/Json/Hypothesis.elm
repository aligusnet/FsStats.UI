module Data.Json.Hypothesis exposing (decoder)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, optional, required)
import Data.Hypothesis exposing (Response, OneSampleMeanTestResult)


decoder : Decode.Decoder Response
decoder =
    decode Response
        |> optional "OneSampleZTest" (Decode.nullable oneSampleMeanTestResultDecoder) Nothing
        |> optional "OneSampleTTest" (Decode.nullable oneSampleMeanTestResultDecoder) Nothing


oneSampleMeanTestResultDecoder : Decode.Decoder OneSampleMeanTestResult
oneSampleMeanTestResultDecoder =
    decode OneSampleMeanTestResult
        |> required "PValue" Decode.float
        |> required "Score" Decode.float
        |> required "RejectedAtSignificanceLevel001" Decode.bool
        |> required "RejectedAtSignificanceLevel005" Decode.bool
        |> required "RejectedAtSignificanceLevel010" Decode.bool
