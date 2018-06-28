module Hypothesis exposing (main)

import Html exposing (..)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import RemoteData
import Data exposing (emptyRequest)
import Data.Hypothesis
import Data.Json as Json
import AWS.Lambda
import Validator exposing (andThen)
import UI
import UI.Property exposing (Property, property)
import UI.Style as Style
import UI.Value


main : Program Never Model Message
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Request =
    Data.Hypothesis.Request


type alias Response =
    Data.Hypothesis.Response


type alias RemoteStatsData =
    RemoteData.RemoteData Data.Error Response


type alias Model =
    { stats : RemoteStatsData
    , trueMean : String
    , stddev : String
    , sampleMean : String
    , sampleSize : String
    , testType : String
    }


type Message
    = FetchStats
    | FetchStatsSuccess String
    | FetchStatsError String
    | ChangeTrueMean String
    | ChangeStddev String
    | ChangeSampleMean String
    | ChangeSampleSize String
    | ChangeTestType Data.Hypothesis.TestType


subscriptions : Model -> Sub Message
subscriptions model =
    Sub.batch
        [ AWS.Lambda.fetchStatsSuccess FetchStatsSuccess
        , AWS.Lambda.fetchStatsError FetchStatsError
        ]


getResponse : Model -> Response
getResponse model =
    case model.stats of
        RemoteData.Success stats ->
            stats

        _ ->
            Data.Hypothesis.emptyResponse


init : ( Model, Cmd Message )
init =
    ( { stats = RemoteData.NotAsked
      , trueMean = ""
      , stddev = ""
      , sampleMean = ""
      , sampleSize = ""
      , testType = ""
      }
    , Cmd.none
    )


fetchStats : Data.Hypothesis.OneSampleMeanTest -> Cmd msg
fetchStats test =
    let
        request =
            { oneSampleZTest = Just test, oneSampleTTest = Just test }
    in
        AWS.Lambda.fetchStats { emptyRequest | hypothesis = Just request }


update : Message -> Model -> ( Model, Cmd Message )
update msg model =
    case msg of
        FetchStats ->
            validateAndFetchStats model

        FetchStatsSuccess value ->
            onFetchStatsSuccess model value

        FetchStatsError error ->
            ( { model | stats = RemoteData.Failure (Data.BadStatus error) }, Cmd.none )

        ChangeTrueMean value ->
            ( { model | trueMean = value }, Cmd.none )

        ChangeStddev value ->
            ( { model | stddev = value }, Cmd.none )

        ChangeSampleMean value ->
            ( { model | sampleMean = value }, Cmd.none )

        ChangeSampleSize value ->
            ( { model | sampleSize = value }, Cmd.none )

        ChangeTestType value ->
            ( { model | testType = Data.Hypothesis.testTypeToString value }, Cmd.none )


validateAndFetchStats : Model -> ( Model, Cmd Message )
validateAndFetchStats model =
    let
        t =
            Result.map Data.Hypothesis.OneSampleMeanTest (Validator.toFloat "Mu" model.trueMean)
                |> andThen (Validator.toNonNegativeFloat "StdDev" model.stddev)
                |> andThen (Validator.toFloat "SampleMean" model.sampleMean)
                |> andThen (Validator.toNonNegativeInt "SampleSize" model.sampleSize)
                |> andThen
                    (if String.isEmpty model.testType then
                        Err "Please select test type"
                     else
                        Ok model.testType
                    )
    in
        case t of
            Ok test ->
                ( { model | stats = RemoteData.Loading }, fetchStats test )

            Err error ->
                ( { model | stats = RemoteData.Failure (Data.BadRequest error) }, Cmd.none )


onFetchStatsSuccess : Model -> String -> ( Model, Cmd Message )
onFetchStatsSuccess model value =
    case Json.decodeResponse value of
        Ok response ->
            case response.hypothesis of
                Just hypothesis ->
                    ( { model | stats = RemoteData.Success hypothesis }, Cmd.none )

                Nothing ->
                    ( { model | stats = RemoteData.Failure (Data.UnexpectedResponse response) }, Cmd.none )

        Err error ->
            ( { model | stats = RemoteData.Failure (Data.BadPayload error) }, Cmd.none )


view : Model -> Html Message
view model =
    let
        response =
            getResponse model
    in
        div [ Attr.class Style.wrapper ]
            [ UI.Property.render propertyTrueMean
            , UI.Property.render propertyStddev
            , UI.Property.render propertySampleMean
            , UI.Property.render propertySampleSize
            , testType
            , UI.Property.render (propertyOneSampleZTest response)
            , UI.Property.render (propertyOneSampleTTest response)
            , UI.submitButton "Retrieve stats" FetchStats
            , UI.error model.stats
            ]


propertyTrueMean : Property Message
propertyTrueMean =
    { property
        | name = "Mu"
        , caption = Just "Population (True) Mean"
        , message = Just ChangeTrueMean
        , placeholder = "e.g. 100.0"
    }


propertyStddev : Property Message
propertyStddev =
    { property
        | caption = Just "Population (Z-Test) or Sample (t-Test) Standard Deviation"
        , name = "Sigma/s"
        , message = Just ChangeStddev
        , placeholder = "e.g. 6.0"
    }


propertySampleMean : Property Message
propertySampleMean =
    { property
        | caption = Just "Sample Mean"
        , name = "Sample Mean"
        , message = Just ChangeSampleMean
        , placeholder = "e.g. 98.0"
    }


propertySampleSize : Property Message
propertySampleSize =
    { property
        | caption = Just "Sample Size"
        , name = "Sample Size"
        , message = Just ChangeSampleSize
        , placeholder = "e.g. 25"
    }


propertyOneSampleZTest : Response -> Property Message
propertyOneSampleZTest response =
    { property
        | name = "Z-Test"
        , value = UI.Value.VFloat response.oneSampleZTest
    }


propertyOneSampleTTest : Response -> Property Message
propertyOneSampleTTest response =
    { property
        | name = "T-Test"
        , value = UI.Value.VFloat response.oneSampleTTest
    }


testType : Html Message
testType =
    let
        controls =
            [ fieldset
                [ Attr.class Style.propertyRowBlock ]
                [ radio "radio-lt" "Lower tailed" (ChangeTestType Data.Hypothesis.LowerTailed)
                , radio "radio-tt" "Two tailed" (ChangeTestType Data.Hypothesis.TwoTailed)
                , radio "radio-ut" "Upper Tailed" (ChangeTestType Data.Hypothesis.UpperTailed)
                ]
            ]
    in
        div [ Attr.class Style.propertyRow ]
            (UI.Property.renderName "Test Type" controls)


radio : String -> String -> Message -> Html Message
radio id_ value msg =
    div [ Attr.class Style.propertyRow ]
        [ input [ Attr.id id_, Attr.type_ "radio", Attr.name "test-type", onClick msg ] []
        , label [ Attr.for id_ ] [ text value ]
        ]
