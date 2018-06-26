module Data.Json exposing (decodeResponse)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, optional)
import Data
import Data.Json.Normal as Normal
import Data.Json.Bernoulli as Bernoulli
import Data.Json.Binomial as Binomial
import Data.Json.Poisson as Poisson
import Data.Json.Students as Students


decodeResponse : String -> Result String Data.Response
decodeResponse value =
    Decode.decodeString responseDecoder value


responseDecoder : Decode.Decoder Data.Response
responseDecoder =
    decode Data.Response
        |> optional "Normal" (Decode.nullable Normal.decoder) Nothing
        |> optional "Bernoulli" (Decode.nullable Bernoulli.decoder) Nothing
        |> optional "Binomial" (Decode.nullable Binomial.decoder) Nothing
        |> optional "Poisson" (Decode.nullable Poisson.decoder) Nothing
        |> optional "Students" (Decode.nullable Students.decoder) Nothing
