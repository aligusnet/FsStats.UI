module UI exposing (..)

import Html exposing (..)
import Html.Attributes as Attr
import Html.Events exposing (..)
import RemoteData
import Array exposing (Array)
import UI.Style as Style


{-| Format error message
-}
error : RemoteData.RemoteData b a -> Html msg
error rsd =
    case rsd of
        RemoteData.NotAsked ->
            text "Please request for stats data"

        RemoteData.Loading ->
            text "Please wait, stats data is loading..."

        RemoteData.Failure err ->
            text ("Error: " ++ toString err)

        RemoteData.Success stats ->
            text ""


{-| Build property row with caption and 3 fields:
text property name, input field and text property value.
-}
propertyInputRowWithCaption : String -> String -> (String -> msg) -> Maybe a -> Html msg
propertyInputRowWithCaption propertyCaption propertyName msg propertyValue =
    div [ Attr.class Style.propertyRowBlock ]
        [ caption propertyCaption
        , propertyInputRow propertyName msg propertyValue
        ]


{-| Build property row with caption and 3 fields:
text property name, input field and text property value.
-}
propertyInputRowArrayValueWithCaption : String -> String -> (String -> msg) -> Maybe (Array a) -> Html msg
propertyInputRowArrayValueWithCaption propertyCaption propertyName msg propertyValue =
    let
        value =
            Maybe.map ((String.join ", ") << (Array.toList) << (Array.map toString)) propertyValue
                |> Maybe.withDefault ""
    in
        div [ Attr.class Style.propertyRowBlock ]
            [ caption propertyCaption
            , propertyInputRow propertyName msg Nothing
            , div []
                [ text value ]
            ]


{-| Build property row with 3 fields:
text property name, input field and text property value.
-}
propertyInputRow : String -> (String -> msg) -> Maybe a -> Html msg
propertyInputRow name msg value =
    let
        s =
            Maybe.withDefault "" (Maybe.map toString value)
    in
        div [ Attr.class Style.propertyRow ]
            [ div [ Attr.class Style.propertyName ]
                [ text name ]
            , div [ Attr.class Style.propertyValue ]
                [ input [ onInput msg ]
                    []
                ]
            , div [ Attr.class Style.propertyValue ]
                [ text s ]
            ]


{-| Build property row with 2 text fields:
property name and property value
-}
propertyRow : String -> String -> Html msg
propertyRow name value =
    div [ Attr.class Style.propertyRow ]
        [ div [ Attr.class Style.propertyName ]
            [ text name ]
        , div [ Attr.class Style.propertyValue ]
            [ text value ]
        ]


{-| Format caption
-}
caption : String -> Html msg
caption caption =
    div [ Attr.class Style.propertyCaption ]
        [ text caption ]


submitButton : String -> msg -> Html msg
submitButton caption msg =
    div [ Attr.class Style.propertyRow ]
        [ div [ Attr.class Style.propertyName ]
            []
        , div [ Attr.class Style.propertyValue ]
            [ button [ onClick msg ]
                [ text caption ]
            ]
        ]


inputRow : String -> String -> (String -> msg) -> Html msg
inputRow name placeholder msg =
    div [ Attr.class Style.propertyRow ]
        [ div [ Attr.class Style.propertyName ]
            [ text name ]
        , div [ Attr.class Style.propertyValue ]
            [ input
                [ Attr.placeholder placeholder
                , onInput msg
                ]
                []
            ]
        ]
