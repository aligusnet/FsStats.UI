module SummaryStatistics exposing (main)

import Array
import Html exposing (..)
import Html.Attributes as Attr
import RemoteData
import Data exposing (emptyRequest)
import Data.SummaryStatistics exposing (Request, Response)
import Data.Json as Json
import AWS.Lambda
import Plotly
import Validator exposing (andThen)
import UI
import UI.Property exposing (Property, property)
import UI.BigProperty exposing (BigProperty)
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


plotName : String
plotName =
    "summary_plot"


type alias RemoteStatsData =
    RemoteData.RemoteData Data.Error Response


type alias Model =
    { stats : RemoteStatsData
    , params : String
    , percentile : String
    , correlation : String
    }


type Message
    = FetchStats
    | FetchStatsSuccess String
    | FetchStatsError String
    | ChangeParams String
    | ChangePercentile String
    | ChangeCorrelation String


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
            Data.SummaryStatistics.emptyResponse


init : ( Model, Cmd Message )
init =
    ( { stats = RemoteData.NotAsked
      , params = ""
      , percentile = ""
      , correlation = ""
      }
    , Cmd.none
    )


fetchStats : Request -> Cmd msg
fetchStats request =
    AWS.Lambda.fetchStats { emptyRequest | summary = Just request }


drawPlot : Maybe (Array.Array Float) -> Cmd msg
drawPlot p =
    Plotly.plotHistogram plotName "Summary Statistics" p


update : Message -> Model -> ( Model, Cmd Message )
update msg model =
    case msg of
        FetchStats ->
            validateAndFetchStats model

        FetchStatsSuccess value ->
            onFetchStatsSuccess model value

        FetchStatsError error ->
            ( { model | stats = RemoteData.Failure (Data.BadStatus error) }, drawPlot Nothing )

        ChangeParams value ->
            ( { model | params = value }, Cmd.none )

        ChangePercentile value ->
            ( { model | percentile = value }, Cmd.none )

        ChangeCorrelation value ->
            ( { model | correlation = value }, Cmd.none )


validateAndFetchStats : Model -> ( Model, Cmd Message )
validateAndFetchStats model =
    let
        r =
            Result.map Request (Validator.toFloatArray "Params" model.params)
                |> andThen (Validator.toMaybeFloatFromInterval "Percentile" 0 1 model.percentile)
                |> andThen (Validator.toMaybeFloatArray "Correlation" model.correlation)
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
            case response.summary of
                Just summary ->
                    ( { model | stats = RemoteData.Success summary }, drawPlot (Just summary.params) )

                Nothing ->
                    ( { model | stats = RemoteData.Failure (Data.BadPayload "No data retrieved") }, drawPlot Nothing )

        Err error ->
            ( { model | stats = RemoteData.Failure (Data.BadPayload error) }, drawPlot Nothing )


view : Model -> Html Message
view model =
    let
        response =
            getResponse model
    in
        div [ Attr.class Style.wrapper ]
            [ UI.BigProperty.render propertyParams
            , viewRemoteStatsData model.stats
            , UI.Property.render (propertyPercentile response)
            , UI.BigProperty.render (propertyCorrelation response)
            , div [ Attr.id plotName ] []
            , UI.submitButton "Retrieve stats" FetchStats
            , UI.error model.stats
            ]


propertyParams : BigProperty Message
propertyParams =
    { name = "Params"
    , message = ChangeParams
    , placeholder = "Space-separated list of numbers.\ne.g.: 10.1 12.3 7.9"
    , value = UI.Value.VNothing
    }


propertyPercentile : Response -> Property Message
propertyPercentile response =
    { property
        | name = "Percentile"
        , message = Just ChangePercentile
        , value = UI.Value.VFloat response.percentile
    }


propertyCorrelation : Response -> BigProperty Message
propertyCorrelation response =
    { name = "Params"
    , message = ChangeCorrelation
    , placeholder = "Space-separated list of numbers.\ne.g.: 10.1 12.3 7.9"
    , value = UI.Value.VFloat response.correlation
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

        makeIntProperty name f =
            { property | name = name, value = UI.Value.VInt (Maybe.map f response) }
    in
        div []
            [ UI.Property.render (makeProperty "Mean" .mean)
            , UI.Property.render (makeProperty "StdDev" .stddev)
            , UI.Property.render (makeProperty "Variance" .variance)
            , UI.Property.render (makeProperty "Skewness" .skewness)
            , UI.Property.render (makeProperty "Kurtosis" .kurtosis)
            , UI.Property.render (makeProperty "Minimum" .minimum)
            , UI.Property.render (makeProperty "Q2" .q2)
            , UI.Property.render (makeProperty "Median" .median)
            , UI.Property.render (makeProperty "Q4" .q4)
            , UI.Property.render (makeProperty "Maximum" .maximum)
            , UI.Property.render (makeProperty "IQR" .iqr)
            , UI.Property.render (makeIntProperty "Size" .size)
            ]
