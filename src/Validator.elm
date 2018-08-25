module Validator exposing (..)

import Array exposing (Array)


andThen : Result x a -> Result x (a -> value) -> Result x value
andThen value func =
    Result.andThen (\f -> Result.map f value) func


toFloat : String -> String -> Result String Float
toFloat field s =
    case String.toFloat s of
        Just f ->
            Ok f

        Nothing ->
            Err (field ++ ": " ++ stringToFloatError)


toNonNegativeFloat : String -> String -> Result String Float
toNonNegativeFloat field s =
    let
        testForNonNegative f =
            if f < 0 then
                Err (field ++ ": value must be non-negative")
            else
                Ok f
    in
        toFloat field s
            |> Result.andThen testForNonNegative


toFloatFromInterval : String -> Float -> Float -> String -> Result String Float
toFloatFromInterval field begin end s =
    let
        testForInterval x =
            if x > begin && x < end then
                Ok x
            else
                Err (field ++ ": floating point value must be between " ++ (String.fromFloat begin) ++ " and " ++ (String.fromFloat end))
    in
        toFloat field s
            |> Result.andThen testForInterval


toMaybeFloatFromInterval : String -> Float -> Float -> String -> Result String (Maybe Float)
toMaybeFloatFromInterval field begin end s =
    if String.isEmpty (String.trim s) then
        Ok Nothing
    else
        case toFloatFromInterval field begin end s of
            Ok i ->
                Ok (Just i)

            Err err ->
                Err err


toMaybeFloat : String -> String -> Result String (Maybe Float)
toMaybeFloat field s =
    if String.isEmpty (String.trim s) then
        Ok Nothing
    else
        case String.toFloat s of
            Just f ->
                Ok (Just f)

            Nothing ->
                Err (field ++ ": " ++ stringToFloatError)


toInt : String -> String -> Result String Int
toInt field s =
    case String.toInt s of
        Just i ->
            Ok i

        Nothing ->
            Err (field ++ ": " ++ stringToIntError)


toMaybeInt : String -> String -> Result String (Maybe Int)
toMaybeInt field s =
    if String.isEmpty (String.trim s) then
        Ok Nothing
    else
        case String.toInt s of
            Just i ->
                Ok (Just i)

            Nothing ->
                Err (field ++ ": " ++ stringToIntError)


toNonNegativeInt : String -> String -> Result String Int
toNonNegativeInt field s =
    let
        testForNonNegative f =
            if f < 0 then
                Err (field ++ ": value must be non-negative")
            else
                Ok f
    in
        toInt field s
            |> Result.andThen testForNonNegative


toIntFromInterval : String -> Int -> Int -> String -> Result String Int
toIntFromInterval field begin end s =
    let
        testForInterval x =
            if x > begin && x < end then
                Ok x
            else
                Err (field ++ ": integer value must be  between " ++ (String.fromInt begin) ++ " and " ++ (String.fromInt end))
    in
        toInt field s
            |> Result.andThen testForInterval


toMaybeIntFromInterval : String -> Int -> Int -> String -> Result String (Maybe Int)
toMaybeIntFromInterval field begin end s =
    if String.isEmpty (String.trim s) then
        Ok Nothing
    else
        case toIntFromInterval field begin end s of
            Ok i ->
                Ok (Just i)

            Err err ->
                Err err


toFloatArray : String -> String -> Result String (Array Float)
toFloatArray field s =
    let
        ar =
            String.split " " (String.trim s)
                |> List.map String.toFloat
                |> transform (Just [])
    in
        case ar of
            Just a ->
                Ok (Array.fromList a)

            Nothing ->
                Err (field ++ ": " ++ stringToFloatError)


toMaybeFloatArray : String -> String -> Result String (Maybe (Array Float))
toMaybeFloatArray field s =
    if String.isEmpty (String.trim s) then
        Ok Nothing
    else
        case toFloatArray field s of
            Ok a ->
                Ok (Just a)

            Err err ->
                Err err


transform : Maybe (List value) -> List (Maybe value) -> Maybe (List value)
transform res lst =
    case lst of
        r :: rs ->
            case r of
                Just x ->
                    transform (Maybe.map2 (::) r res) rs

                Nothing ->
                    Nothing

        [] ->
            res


stringToFloatError : String
stringToFloatError =
    "failed to convert string value to floating-point number"


stringToIntError : String
stringToIntError =
    "failed to convert string value to integer number"
