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
                String.fromInt i

            VInt Nothing ->
                ""

            VFloat (Just f) ->
                String.fromFloat f

            VFloat Nothing ->
                ""

            VBool (Just b) ->
                stringFromBool b

            VBool Nothing ->
                ""

            VArrayInt (Just array) ->
                Array.map String.fromInt array
                    |> Array.toList
                    |> String.join sep

            VArrayInt Nothing ->
                ""

            VArrayFloat (Just array) ->
                Array.map String.fromFloat array
                    |> Array.toList
                    |> String.join sep

            VArrayFloat Nothing ->
                ""

            VNothing ->
                ""


stringFromBool : Bool -> String
stringFromBool b =
    case b of
        True ->
            "true"

        False ->
            "false"
