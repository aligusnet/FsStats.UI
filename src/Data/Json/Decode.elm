module Data.Json.Decode exposing (..)

import Array exposing (Array)
import Json.Decode as Decode


decodePairOfFloatArrays : Decode.Decoder ( Array Float, Array Float )
decodePairOfFloatArrays =
    Decode.map2 (,) (Decode.index 0 decodeFloatArray) (Decode.index 1 decodeFloatArray)


decodePairOfIntFloatArrays : Decode.Decoder ( Array Int, Array Float )
decodePairOfIntFloatArrays =
    Decode.map2 (,) (Decode.index 0 decodeIntArray) (Decode.index 1 decodeFloatArray)


decodeFloatArray : Decode.Decoder (Array Float)
decodeFloatArray =
    Decode.array Decode.float


decodeIntArray : Decode.Decoder (Array Int)
decodeIntArray =
    Decode.array Decode.int
