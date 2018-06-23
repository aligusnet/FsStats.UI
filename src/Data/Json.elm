module Data.Json exposing (decodeResponse)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required, optional)
import Array exposing (Array)
import Data


decodeResponse : String -> Result String Data.Response
decodeResponse value =
    Decode.decodeString responseDecoder value


responseDecoder : Decode.Decoder Data.Response
responseDecoder =
    decode Data.Response
        |> optional "Normal" (Decode.nullable normalResponseDecoder) Nothing


normalResponseDecoder : Decode.Decoder Data.NormalResponse
normalResponseDecoder =
    decode Data.NormalResponse
        |> required "Params" normalParamsDecoder
        |> required "Mean" Decode.float
        |> required "StdDev" Decode.float
        |> required "Variance" Decode.float
        |> optional "Curve" (Decode.nullable decodePairOfFloatArrays) Nothing
        |> optional "Pdf" (Decode.nullable Decode.float) Nothing
        |> optional "Cdf" (Decode.nullable Decode.float) Nothing
        |> optional "Quantile" (Decode.nullable Decode.float) Nothing
        |> optional "Sample" (Decode.nullable decodeFloarArray) Nothing


normalParamsDecoder : Decode.Decoder Data.NormalParams
normalParamsDecoder =
    decode Data.NormalParams
        |> required "Mu" Decode.float
        |> required "Sigma" Decode.float


decodePairOfFloatArrays : Decode.Decoder ( Array Float, Array Float )
decodePairOfFloatArrays =
    Decode.map2 (,) (Decode.index 0 decodeFloarArray) (Decode.index 1 decodeFloarArray)


decodeFloarArray : Decode.Decoder (Array Float)
decodeFloarArray =
    Decode.array Decode.float
