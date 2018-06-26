module Bernoulli exposing (main)

import Array
import Html exposing (..)
import Html.Attributes as Attr
import RemoteData
import Data exposing (emptyRequest)
import Data.Bernoulli
import Data.Json as Json
import AWS.Lambda
import Plotly
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


plotName : String
plotName =
    "bernoulli_plot"


type alias Request =
    Data.Bernoulli.Request


type alias Response =
    Data.Bernoulli.Response


type alias RemoteStatsData =
    RemoteData.RemoteData Data.Error Response


type alias Model =
    { stats : RemoteStatsData
    , p : String
    , pmf : String
    , cdf : String
    , sample : String
    }


type Message
    = FetchStats
    | FetchStatsSuccess String
    | FetchStatsError String
    | ChangeP String
    | ChangePmf String
    | ChangeCdf String
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
            Data.Bernoulli.emptyResponse


init : ( Model, Cmd Message )
init =
    ( { stats = RemoteData.NotAsked
      , p = ""
      , pmf = ""
      , cdf = ""
      , sample = ""
      }
    , Cmd.none
    )


fetchStats : Request -> Cmd msg
fetchStats request =
    AWS.Lambda.fetchStats { emptyRequest | bernoulli = Just request }


drawPlot : Maybe Float -> Cmd msg
drawPlot p =
    let
        bar =
            case p of
                Just p_ ->
                    Just ( Array.fromList [ 0.0, 1.0 ], Array.fromList [ 1.0 - p_, p_ ] )

                Nothing ->
                    Nothing
    in
        Plotly.plotBar plotName "Bernoulli Distribution" bar


update : Message -> Model -> ( Model, Cmd Message )
update msg model =
    case msg of
        FetchStats ->
            validateAndFetchStats model

        FetchStatsSuccess value ->
            onFetchStatsSuccess model value

        FetchStatsError error ->
            ( { model | stats = RemoteData.Failure (Data.BadStatus error) }, drawPlot Nothing )

        ChangeP value ->
            ( { model | p = value }, Cmd.none )

        ChangePmf value ->
            ( { model | pmf = value }, Cmd.none )

        ChangeCdf value ->
            ( { model | cdf = value }, Cmd.none )

        ChangeSample value ->
            ( { model | sample = value }, Cmd.none )


validateAndFetchStats : Model -> ( Model, Cmd Message )
validateAndFetchStats model =
    let
        r =
            Result.map Data.Bernoulli.Request (toParams model.p)
                |> andThen (Validator.toMaybeIntFromInterval "PMF" -1 3 model.pmf)
                |> andThen (Validator.toMaybeIntFromInterval "CDF" -1 3 model.cdf)
                |> andThen (Validator.toMaybeIntFromInterval "Sample" 0 101 model.sample)
    in
        case r of
            Ok request ->
                ( { model | stats = RemoteData.Loading }, fetchStats request )

            Err error ->
                ( { model | stats = RemoteData.Failure (Data.BadRequest error) }, drawPlot Nothing )


toParams : String -> Result String Data.Bernoulli.Params
toParams p =
    Result.map Data.Bernoulli.Params
        (Validator.toFloatFromInterval "Probability" 0.0 1.0 p)


onFetchStatsSuccess : Model -> String -> ( Model, Cmd Message )
onFetchStatsSuccess model value =
    case Json.decodeResponse value of
        Ok response ->
            case response.bernoulli of
                Just bernoulli ->
                    ( { model | stats = RemoteData.Success bernoulli }, drawPlot (Just bernoulli.params.p) )

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
            [ UI.Property.render propertyProbability
            , viewRemoteStatsData model.stats
            , UI.Property.render (propertyPmf response)
            , UI.Property.render (propertyCdf response)
            , UI.Property.render (propertySample response)
            , div [ Attr.id plotName ] []
            , UI.submitButton "Retrieve stats" FetchStats
            , UI.error model.stats
            ]


propertyProbability : Property Message
propertyProbability =
    { property
        | name = "Probability"
        , message = Just ChangeP
        , placeholder = "e.g. 0.7"
    }


propertyPmf : Response -> Property Message
propertyPmf response =
    { property
        | caption = Just "Probability mass function (PMF)"
        , name = "x"
        , message = Just ChangePmf
        , value = UI.Value.VFloat response.pmf
    }


propertyCdf : Response -> Property Message
propertyCdf response =
    { property
        | caption = Just "Cumulative distribution function (CDF)"
        , name = "x"
        , message = Just ChangeCdf
        , value = UI.Value.VFloat response.cdf
    }


propertySample : Response -> Property Message
propertySample response =
    { property
        | caption = Just "Random Sample"
        , name = "Size"
        , message = Just ChangeSample
        , value = UI.Value.VArrayInt response.sample
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
