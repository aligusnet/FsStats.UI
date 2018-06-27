module UI.Property exposing (Property, property, render, renderName)

import Html exposing (..)
import Html.Attributes as Attr
import Html.Events exposing (..)
import UI.Style as Style
import UI.Value exposing (Value(..), valueToString)


type alias Property msg =
    { name : String
    , value : Value
    , message : Maybe (String -> msg)
    , placeholder : String
    , caption : Maybe String
    }


property : Property msg
property =
    { name = ""
    , value = VNothing
    , message = Nothing
    , caption = Nothing
    , placeholder = ""
    }


render : Property msg -> Html msg
render property =
    let
        controls =
            renderCaption property [ renderRow property ]
    in
        div [ Attr.class Style.propertyRowBlock ]
            controls


renderCaption : Property msg -> List (Html msg) -> List (Html msg)
renderCaption property controls =
    case property.caption of
        Just caption ->
            (div [ Attr.class Style.propertyCaption ] [ text caption ]) :: controls

        Nothing ->
            controls


renderRow : Property msg -> Html msg
renderRow property =
    let
        controls =
            renderName property.name []
                |> renderInput property
                |> renderValue property
                |> List.reverse
    in
        div [ Attr.class Style.propertyRow ] controls


renderName : String -> List (Html msg) -> List (Html msg)
renderName name controls =
    div [ Attr.class Style.propertyName ] [ text name ] :: controls


renderInput : Property msg -> List (Html msg) -> List (Html msg)
renderInput property controls =
    case property.message of
        Just message ->
            div [ Attr.class Style.propertyValue ]
                [ input [ Attr.placeholder property.placeholder, onInput message ] [] ]
                :: controls

        Nothing ->
            controls


renderValue : Property msg -> List (Html msg) -> List (Html msg)
renderValue property controls =
    let
        str =
            valueToString property.value

        isLongValue =
            String.length str > 50
    in
        if isLongValue then
            textarea [ Attr.readonly True ] [ text str ] :: controls
        else
            div [ Attr.class Style.propertyValue ] [ text str ] :: controls
