module Students exposing (main)

import Array exposing (Array)
import Browser
import Html exposing (..)
import Html.Attributes as Attr
import RemoteData
import Data exposing (emptyRequest)
import Data.Students
import Data.Json as Json
import AWS.Lambda
import Plotly
import Validator exposing (andThen)
import UI
import UI.Property exposing (Property, property)
import UI.Style as Style
import UI.Value


main : Program () Model Message
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


plotName : String
plotName =
    "students_plot"


type alias Response =
    Data.Students.Response


type alias RemoteStatsData =
    RemoteData.RemoteData Data.Error Response


type alias Model =
    { stats : RemoteStatsData
    , nu : String
    , pdf : String
    , cdf : String
    , quantile : String
    , sample : String
    }


type Message
    = FetchStats
    | FetchStatsSuccess String
    | FetchStatsError String
    | ChangeNu String
    | ChangePdf String
    | ChangeCdf String
    | ChangeQuantile String
    | ChangeSample String


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
            Data.Students.emptyResponse


init : () -> ( Model, Cmd Message )
init _ =
    ( { stats = RemoteData.NotAsked
      , nu = ""
      , pdf = ""
      , cdf = ""
      , quantile = ""
      , sample = ""
      }
    , Cmd.none
    )


fetchStats : Data.Students.Request -> Cmd msg
fetchStats request =
    AWS.Lambda.fetchStats { emptyRequest | students = Just request }


drawPlot : Maybe ( Array.Array Float, Array.Array Float ) -> Cmd msg
drawPlot curve =
    Plotly.plotLine plotName "Student's T-Distribution" curve


update : Message -> Model -> ( Model, Cmd Message )
update msg model =
    case msg of
        FetchStats ->
            validateAndFetchStats model

        FetchStatsSuccess value ->
            onFetchStatsSuccess model value

        FetchStatsError error ->
            ( { model | stats = RemoteData.Failure (Data.BadStatus error) }, drawPlot Nothing )

        ChangeNu value ->
            ( { model | nu = value }, Cmd.none )

        ChangePdf value ->
            ( { model | pdf = value }, Cmd.none )

        ChangeCdf value ->
            ( { model | cdf = value }, Cmd.none )

        ChangeQuantile value ->
            ( { model | quantile = value }, Cmd.none )

        ChangeSample value ->
            ( { model | sample = value }, Cmd.none )


validateAndFetchStats : Model -> ( Model, Cmd Message )
validateAndFetchStats model =
    let
        r =
            Result.map Data.Students.Request (toParams model.nu)
                |> andThen (Ok (Just 40))
                |> andThen (Validator.toMaybeFloat "PDF" model.pdf)
                |> andThen (Validator.toMaybeFloat "CDF" model.cdf)
    in
        case r of
            Ok request ->
                ( { model | stats = RemoteData.Loading }, fetchStats request )

            Err error ->
                ( { model | stats = RemoteData.Failure (Data.BadRequest error) }, drawPlot Nothing )


onFetchStatsSuccess : Model -> String -> ( Model, Cmd Message )
onFetchStatsSuccess model value =
    case Json.decodeResponse value of
        Ok response ->
            case response.students of
                Just students ->
                    ( { model | stats = RemoteData.Success students }, drawPlot students.curve )

                Nothing ->
                    ( { model | stats = RemoteData.Failure (Data.UnexpectedResponse response) }, drawPlot Nothing )

        Err error ->
            ( { model | stats = RemoteData.Failure (Data.BadPayload error) }, drawPlot Nothing )


toParams : String -> Result String Data.Students.Params
toParams nu =
    Result.map Data.Students.Params (Validator.toFloatFromInterval "Degrees of freedom" 2.0 201.0 nu)


view : Model -> Html Message
view model =
    let
        response =
            getResponse model
    in
        div [ Attr.class Style.wrapper ]
            [ UI.Property.render propertyNu
            , viewRemoteStatsData model.stats
            , UI.Property.render (propertyPdf response)
            , UI.Property.render (propertyCdf response)
            , div [ Attr.id plotName ] []
            , UI.submitButton "Retrieve stats" FetchStats
            , UI.error model.stats
            ]


propertyNu : Property Message
propertyNu =
    { property
        | name = "Degrees of freedom"
        , message = Just ChangeNu
        , placeholder = "nu, e.g. 20"
    }


propertyPdf : Response -> Property Message
propertyPdf response =
    { property
        | caption = Just "Probability density function (PDF)"
        , name = "x"
        , message = Just ChangePdf
        , value = UI.Value.VFloat response.pdf
    }


propertyCdf : Response -> Property Message
propertyCdf response =
    { property
        | caption = Just "Cumulative distribution function (CDF)"
        , name = "x"
        , message = Just ChangeCdf
        , value = UI.Value.VFloat response.cdf
    }


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
            [ UI.Property.render (makeProperty "Mean" .mean)
            , UI.Property.render (makeProperty "StdDev" .stddev)
            , UI.Property.render (makeProperty "Variance" .variance)
            ]
