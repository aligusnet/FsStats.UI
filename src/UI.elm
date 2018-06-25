module UI exposing (..)

import Html exposing (..)
import Html.Attributes as Attr
import Html.Events exposing (..)
import RemoteData
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
            div [ Attr.class Style.error ]
                [ text ("Error: " ++ toString err) ]

        RemoteData.Success stats ->
            text ""


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
