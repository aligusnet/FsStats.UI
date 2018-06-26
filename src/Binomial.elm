module Binomial exposing (main)

import Array
import Html exposing (..)
import Html.Attributes as Attr
import RemoteData
import Data exposing (emptyRequest)
import Data.Binomial
import Data.Json as Json
import AWS.Lambda
import Plotly
import Validator exposing (andThen)
import UI
import UI.Property exposing (Property, property)
import UI.Style as Style


main : Program Never Model Message
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Response =
    Data.Binomial.Response


type alias RemoteStatsData =
    RemoteData.RemoteData Data.Error Response


type alias Model =
    { stats : RemoteStatsData
    , numberOfTrials : String
    , p : String
    , pmf : String
    , cdf : String
    , sample : String
    }


type Message
    = FetchStats
    | FetchStatsSuccess String
    | FetchStatsError String
    | ChangeNumberOfTrials String
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
            Data.Binomial.emptyResponse


init : ( Model, Cmd Message )
init =
    ( { stats = RemoteData.NotAsked
      , numberOfTrials = ""
      , p = ""
      , pmf = ""
      , cdf = ""
      , sample = ""
      }
    , Cmd.none
    )


fetchStats : Data.Binomial.Request -> Cmd msg
fetchStats request =
    AWS.Lambda.fetchStats { emptyRequest | binomial = Just request }


drawPlot : Maybe ( Array.Array Int, Array.Array Float ) -> Cmd msg
drawPlot curve =
    let
        curve_ =
            case curve of
                Just ( x, y ) ->
                    (Just ( Array.map toFloat x, y ))

                Nothing ->
                    Nothing
    in
        Plotly.plotLine "binomial_plot" "Binomial Distribution" curve_


update : Message -> Model -> ( Model, Cmd Message )
update msg model =
    case msg of
        FetchStats ->
            validateAndFetchStats model

        FetchStatsSuccess value ->
            onFetchStatsSuccess model value

        FetchStatsError error ->
            ( { model | stats = RemoteData.Failure (Data.BadStatus error) }, drawPlot Nothing )

        ChangeNumberOfTrials value ->
            ( { model | numberOfTrials = value }, Cmd.none )

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
            Result.map Data.Binomial.Request (toParams model.numberOfTrials model.p)
                |> andThen (Ok (Just 40))
                |> andThen (Validator.toMaybeIntFromInterval "PMF" 0 201 model.pmf)
                |> andThen (Validator.toMaybeIntFromInterval "CDF" 0 201 model.cdf)
                |> andThen (Validator.toMaybeIntFromInterval "Sample" 0 101 model.sample)
    in
        case r of
            Ok request ->
                ( { model | stats = RemoteData.Loading }, fetchStats { request | curve = Just (request.params.numberOfTrials + 1) } )

            Err error ->
                ( { model | stats = RemoteData.Failure (Data.BadRequest error) }, drawPlot Nothing )


toParams : String -> String -> Result String Data.Binomial.Params
toParams n p =
    Result.map2 Data.Binomial.Params
        (Validator.toIntFromInterval "NumberOfTrials" 0 201 n)
        (Validator.toFloatFromInterval "Probability" 0.0 1.0 p)


onFetchStatsSuccess : Model -> String -> ( Model, Cmd Message )
onFetchStatsSuccess model value =
    case Json.decodeResponse value of
        Ok response ->
            case response.binomial of
                Just binomial ->
                    ( { model | stats = RemoteData.Success binomial }, drawPlot binomial.curve )

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
            [ UI.Property.render propertyNumberOfTrials
            , UI.Property.render propertyProbability
            , viewRemoteStatsData model.stats
            , UI.Property.render (propertyPmf response)
            , UI.Property.render (propertyCdf response)
            , UI.Property.render (propertySample response)
            , div [ Attr.id "binomial_plot" ] []
            , UI.submitButton "Retrieve stats" FetchStats
            , UI.error model.stats
            ]


propertyNumberOfTrials : Property Message
propertyNumberOfTrials =
    { property
        | name = "NumberOfTrials"
        , message = Just ChangeNumberOfTrials
        , placeholder = "e.g. 10"
    }


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
        , value = UI.Property.VFloat response.pmf
    }


propertyCdf : Response -> Property Message
propertyCdf response =
    { property
        | caption = Just "Cumulative distribution function (CDF)"
        , name = "x"
        , message = Just ChangeCdf
        , value = UI.Property.VFloat response.cdf
    }


propertySample : Response -> Property Message
propertySample response =
    { property
        | caption = Just "Random Sample"
        , name = "Size"
        , message = Just ChangeSample
        , value = UI.Property.VArrayInt response.sample
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
            { property | name = name, value = UI.Property.VFloat (Maybe.map f response) }

        makeBoolProperty name f =
            { property | name = name, value = UI.Property.VBool (Maybe.map f response) }
    in
        div []
            [ UI.Property.render (makeProperty "Mean" .mean)
            , UI.Property.render (makeProperty "StdDev" .stddev)
            , UI.Property.render (makeProperty "Variance" .variance)
            , UI.Property.render (makeBoolProperty "isNormalApproximationApplicable" .isNormalApproximationApplicable)
            ]
