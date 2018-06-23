module Validator exposing (..)


andThen : Result x a -> Result x (a -> value) -> Result x value
andThen value func =
    Result.andThen (\f -> Result.map f value) func


toFloat : String -> String -> Result String Float
toFloat field s =
    case String.toFloat s of
        Ok f ->
            Ok f

        Err err ->
            Err (field ++ ": " ++ err)


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
            if x < begin || x >= end then
                Err (field ++ ": floating point value must be in interval [" ++ (toString begin) ++ ", " ++ (toString end) ++ ")")
            else
                Ok x
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
            Ok f ->
                Ok (Just f)

            Err err ->
                Err (field ++ ": " ++ err)


toInt : String -> String -> Result String Int
toInt field s =
    case String.toInt s of
        Ok i ->
            Ok i

        Err err ->
            Err (field ++ ": " ++ err)


toMaybeInt : String -> String -> Result String (Maybe Int)
toMaybeInt field s =
    if String.isEmpty (String.trim s) then
        Ok Nothing
    else
        case String.toInt s of
            Ok i ->
                Ok (Just i)

            Err err ->
                Err (field ++ ": " ++ err)


toIntFromInterval : String -> Int -> Int -> String -> Result String Int
toIntFromInterval field begin end s =
    let
        testForInterval x =
            if x < begin || x >= end then
                Err (field ++ ": integer value must be in interval [" ++ (toString begin) ++ ", " ++ (toString end) ++ ")")
            else
                Ok x
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
