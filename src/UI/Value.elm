module UI.Value exposing (..)

import Array exposing (Array)


type Value
    = VInt (Maybe Int)
    | VFloat (Maybe Float)
    | VBool (Maybe Bool)
    | VArrayInt (Maybe (Array Int))
    | VArrayFloat (Maybe (Array Float))
    | VNothing


valueToString : Value -> String
valueToString value =
    let
        sep =
            " "
    in
        case value of
            VInt (Just i) ->
                toString i

            VInt Nothing ->
                ""

            VFloat (Just f) ->
                toString f

            VFloat Nothing ->
                ""

            VBool (Just b) ->
                toString b

            VBool Nothing ->
                ""

            VArrayInt (Just array) ->
                Array.map toString array
                    |> Array.toList
                    |> String.join sep

            VArrayInt Nothing ->
                ""

            VArrayFloat (Just array) ->
                Array.map toString array
                    |> Array.toList
                    |> String.join sep

            VArrayFloat Nothing ->
                ""

            VNothing ->
                ""
