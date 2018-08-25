module Data.Json.SummaryStatistics exposing (decoder)

import Json.Decode as Decode exposing (succeed)
import Json.Decode.Pipeline exposing (required, optional)
import Data.SummaryStatistics exposing (Response)
import Data.Json.Decode exposing (decodeFloatArray)


decoder : Decode.Decoder Response
decoder =
    succeed Response
        |> required "Params" decodeFloatArray
        |> required "Mean" Decode.float
        |> required "StdDev" Decode.float
        |> required "Variance" Decode.float
        |> required "Skewness" Decode.float
        |> required "Kurtosis" Decode.float
        |> required "Minimum" Decode.float
        |> required "Q2" Decode.float
        |> required "Median" Decode.float
        |> required "Q4" Decode.float
        |> required "Maximum" Decode.float
        |> required "IQR" Decode.float
        |> required "Size" Decode.int
        |> optional "Percentile" (Decode.nullable Decode.float) Nothing
        |> optional "Correlation" (Decode.nullable Decode.float) Nothing
