module UI.BigProperty exposing (..)

import Html exposing (..)
import Html.Attributes as Attr
import Html.Events exposing (..)
import UI.Style as Style
import UI.Value exposing (Value, valueToString)


type alias BigProperty msg =
    { name : String
    , value : Value
    , message : String -> msg
    , placeholder : String
    }


render : BigProperty msg -> Html msg
render property =
    div [ Attr.class Style.propertyRowBlock ]
        [ renderName property.name
        , renderInput property
        , renderValue property.value
        ]


renderName : String -> Html msg
renderName name =
    div [ Attr.class Style.propertyCaption ] [ text name ]


renderInput : BigProperty msg -> Html msg
renderInput property =
    div []
        [ textarea
            [ Attr.placeholder property.placeholder
            , onInput property.message
            ]
            []
        ]


renderValue : Value -> Html msg
renderValue value =
    let
        str =
            valueToString value
    in
        div [] [ text str ]
