module Data.Json.OnePopulationMeanTest exposing (decoder)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Data.OnePopulationMeanTest exposing (Response)


decoder : Decode.Decoder Response
decoder =
    decode Response
        |> required "Score" Decode.float
        |> required "ZTest" Decode.float
        |> required "TTest" Decode.float
