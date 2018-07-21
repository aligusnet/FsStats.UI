module OnePopulationMeanTest exposing (main)

import Html exposing (..)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import RemoteData
import Data exposing (emptyRequest)
import Data.TestType as TestType
import Data.OnePopulationMeanTest exposing (Request, Response, Params)
import Data.Json as Json
import AWS.Lambda
import Validator exposing (andThen)
import UI
import UI.Property exposing (Property, property)
import UI.Style as Style
import UI.TestResult
import UI.Value


main : Program Never Model Message
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias RemoteStatsData =
    RemoteData.RemoteData Data.Error Response


type alias Model =
    { stats : RemoteStatsData
    , populationMean : String
    , stddev : String
    , sampleMean : String
    , sampleSize : String
    , testType : String
    }


type Message
    = FetchStats
    | FetchStatsSuccess String
    | FetchStatsError String
    | ChangePopulationMean String
    | ChangeStddev String
    | ChangeSampleMean String
    | ChangeSampleSize String
    | ChangeTestType TestType.TestType


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
            Data.OnePopulationMeanTest.emptyResponse


init : ( Model, Cmd Message )
init =
    ( { stats = RemoteData.NotAsked
      , populationMean = ""
      , stddev = ""
      , sampleMean = ""
      , sampleSize = ""
      , testType = ""
      }
    , Cmd.none
    )


fetchStats : Request -> Cmd msg
fetchStats request =
    AWS.Lambda.fetchStats
        { emptyRequest
            | onePopulationMeanTest = Just request
        }


update : Message -> Model -> ( Model, Cmd Message )
update msg model =
    case msg of
        FetchStats ->
            validateAndFetchStats model

        FetchStatsSuccess value ->
            onFetchStatsSuccess model value

        FetchStatsError error ->
            ( { model | stats = RemoteData.Failure (Data.BadStatus error) }, Cmd.none )

        ChangePopulationMean value ->
            ( { model | populationMean = value }, Cmd.none )

        ChangeStddev value ->
            ( { model | stddev = value }, Cmd.none )

        ChangeSampleMean value ->
            ( { model | sampleMean = value }, Cmd.none )

        ChangeSampleSize value ->
            ( { model | sampleSize = value }, Cmd.none )

        ChangeTestType value ->
            ( { model | testType = TestType.toString value }, Cmd.none )


validateAndFetchStats : Model -> ( Model, Cmd Message )
validateAndFetchStats model =
    let
        t =
            Result.map Request (toParams model)
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


toParams : Model -> Result String Params
toParams model =
    Result.map Params (Validator.toFloat "Mu" model.populationMean)
        |> andThen (Validator.toFloat "SampleMean" model.sampleMean)
        |> andThen (Validator.toNonNegativeInt "SampleSize" model.sampleSize)
        |> andThen (Validator.toNonNegativeFloat "StdDev" model.stddev)


onFetchStatsSuccess : Model -> String -> ( Model, Cmd Message )
onFetchStatsSuccess model value =
    case Json.decodeResponse value of
        Ok response ->
            case response.onePopulationMeanTest of
                Just test ->
                    ( { model | stats = RemoteData.Success test }, Cmd.none )

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
            ([ UI.Property.render propertyPopulationMean
             , UI.Property.render propertyStddev
             , UI.Property.render propertySampleMean
             , UI.Property.render propertySampleSize
             , testType
             , viewRemoteStatsData model.stats
             , UI.submitButton "Retrieve stats" FetchStats
             , UI.error model.stats
             ]
            )


propertyPopulationMean : Property Message
propertyPopulationMean =
    { property
        | name = "Mu"
        , caption = Just "Population (True) Mean"
        , message = Just ChangePopulationMean
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


testType : Html Message
testType =
    let
        controls =
            [ fieldset
                [ Attr.class Style.propertyRowBlock ]
                [ radio "radio-lt" "Lower tailed" (ChangeTestType TestType.LowerTailed)
                , radio "radio-tt" "Two tailed" (ChangeTestType TestType.TwoTailed)
                , radio "radio-ut" "Upper Tailed" (ChangeTestType TestType.UpperTailed)
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


viewRemoteStatsData : RemoteStatsData -> Html Message
viewRemoteStatsData rsd =
    let
        response =
            case rsd of
                RemoteData.Success stats ->
                    Just stats

                _ ->
                    Nothing

        makeProperty name f =
            { property | name = name, value = UI.Value.VFloat (Maybe.map f response) }
    in
        div []
            [ UI.TestResult.render (zTestResult response)
            , UI.TestResult.render (tTestResult response)
            , UI.Property.render (makeProperty "Score" .score)
            , UI.Property.render (makeProperty "Z-Test" .zTest)
            , UI.Property.render (makeProperty "t-Test" .tTest)
            ]


zTestResult : Maybe Response -> UI.TestResult.TestResult
zTestResult response =
    let
        testResult =
            UI.TestResult.testResult "One sample Z-Test"
    in
        { testResult
            | score = Maybe.map .score response
            , pValue = Maybe.map .zTest response
        }


tTestResult : Maybe Response -> UI.TestResult.TestResult
tTestResult response =
    let
        testResult =
            UI.TestResult.testResult "One sample t-Test"
    in
        { testResult
            | score = Maybe.map .score response
            , pValue = Maybe.map .tTest response
        }
