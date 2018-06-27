module UI exposing (error, submitButton)

import Html exposing (..)
import Html.Attributes as Attr
import Html.Events exposing (..)
import RemoteData
import UI.Style as Style
import Data


{-| Format error message
-}
error : RemoteData.RemoteData Data.Error a -> Html msg
error rsd =
    case rsd of
        RemoteData.NotAsked ->
            text "Please request for stats data"

        RemoteData.Loading ->
            text "Please wait, stats data is loading..."

        RemoteData.Failure f ->
            div [ Attr.class Style.error ]
                [ text ("Error: " ++ formatFailure f) ]

        RemoteData.Success stats ->
            text ""


formatFailure : Data.Error -> String
formatFailure failure =
    case failure of
        Data.BadStatus err ->
            "Bad status: " ++ err

        Data.BadRequest err ->
            "Bad request: " ++ err

        Data.BadPayload err ->
            "Bad payload: " ++ err

        Data.UnexpectedResponse response ->
            formatUnexpectedResponseError response


formatUnexpectedResponseError : { a | errorMessage : Maybe String, errorType : Maybe String } -> String
formatUnexpectedResponseError response =
    case ( response.errorType, response.errorMessage ) of
        ( Just errorType, Just errorMessage ) ->
            errorType ++ ":  " ++ errorMessage

        ( Just errorType, Nothing ) ->
            errorType

        ( Nothing, Just errorMessage ) ->
            errorMessage

        ( Nothing, Nothing ) ->
            "Got unexpected payload: " ++ (toString response)


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
