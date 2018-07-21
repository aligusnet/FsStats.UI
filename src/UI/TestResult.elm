module UI.TestResult exposing (..)

import Html exposing (..)
import Html.Attributes as Attr
import UI.Style as Style
import UI.Value exposing (Value(..), valueToString)
import UI.Property as Property


type alias TestResult =
    { score : Maybe Float
    , pValue : Maybe Float
    , significanceLevels : List Float
    , caption : String
    }


testResult : String -> TestResult
testResult testName =
    { score = Nothing
    , pValue = Nothing
    , significanceLevels = [ 0.01, 0.05, 0.1 ]
    , caption = testName ++ " (rejection of null hypothesis)"
    }


render : TestResult -> Html msg
render result =
    div [ Attr.class Style.propertyRowBlock ]
        ([ Property.render (propertyPValue result.caption result.pValue)
         , Property.render (propertyScore result.score)
         ]
            ++ renderPropertySLList result.pValue result.significanceLevels
        )


propertyPValue : String -> Maybe Float -> Property.Property msg
propertyPValue name value =
    { property
        | name = "p-value"
        , caption = Just name
        , value = UI.Value.VFloat value
    }


propertyScore : Maybe Float -> Property.Property msg
propertyScore score =
    { property
        | name = "score"
        , value = UI.Value.VFloat score
    }


renderPropertySLList : Maybe Float -> List Float -> List (Html msg)
renderPropertySLList pValue sls =
    propertySLList pValue sls
        |> List.map Property.render


propertySLList : Maybe Float -> List Float -> List (Property.Property msg)
propertySLList pValue sls =
    List.map (propertySL pValue) sls


propertySL : Maybe Float -> Float -> Property.Property msg
propertySL pValue slValue =
    { property
        | name = "Reject at SL " ++ toString slValue
        , value = UI.Value.VBool (Maybe.map2 (<) pValue (Just slValue))
    }


property : Property.Property msg
property =
    Property.property
