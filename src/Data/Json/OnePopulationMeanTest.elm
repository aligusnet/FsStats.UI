module Data.Json.OnePopulationMeanTest exposing (decoder)

import Json.Decode as Decode exposing (succeed)
import Json.Decode.Pipeline exposing (required)
import Data.OnePopulationMeanTest exposing (Response)


decoder : Decode.Decoder Response
decoder =
    succeed Response
        |> required "Score" Decode.float
        |> required "ZTest" Decode.float
        |> required "TTest" Decode.float
