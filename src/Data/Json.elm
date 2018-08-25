module Data.Json exposing (decodeResponse)

import Json.Decode as Decode exposing (succeed)
import Json.Decode.Pipeline exposing (optional)
import Data
import Data.Json.Normal as Normal
import Data.Json.Bernoulli as Bernoulli
import Data.Json.Binomial as Binomial
import Data.Json.Poisson as Poisson
import Data.Json.Students as Students
import Data.Json.SummaryStatistics as SummaryStatistics
import Data.Json.OnePopulationMeanTest as OnePopulationMeanTest


decodeResponse : String -> Result String Data.Response
decodeResponse value =
    case Decode.decodeString responseDecoder value of
        Ok response ->
            Ok response

        Err decodeError ->
            Err (Decode.errorToString decodeError)


responseDecoder : Decode.Decoder Data.Response
responseDecoder =
    succeed Data.Response
        |> optional "Normal" (Decode.nullable Normal.decoder) Nothing
        |> optional "Bernoulli" (Decode.nullable Bernoulli.decoder) Nothing
        |> optional "Binomial" (Decode.nullable Binomial.decoder) Nothing
        |> optional "Poisson" (Decode.nullable Poisson.decoder) Nothing
        |> optional "Students" (Decode.nullable Students.decoder) Nothing
        |> optional "Summary" (Decode.nullable SummaryStatistics.decoder) Nothing
        |> optional "OnePopulationMeanTest" (Decode.nullable OnePopulationMeanTest.decoder) Nothing
        |> optional "errorType" (Decode.nullable Decode.string) Nothing
        |> optional "errorMessage" (Decode.nullable Decode.string) Nothing
