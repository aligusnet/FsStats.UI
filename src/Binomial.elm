module Binomial exposing (main)

import Array
import Html exposing (..)
import Html.Attributes as Attr
import RemoteData
import Data exposing (emptyRequest)
import Data.Json as Json
import AWS.Lambda
import Plotty
import Validator exposing (andThen)
import UI
import UI.Style as Style


main : Program Never Model Message
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias RemoteStatsData =
    RemoteData.RemoteData Data.Error Data.BinomialResponse


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


getResponse : Model -> Data.BinomialResponse
getResponse model =
    case model.stats of
        RemoteData.Success stats ->
            stats

        _ ->
            Data.emptyBinomialResponse


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


fetchStats : Data.BinomialRequest -> Cmd msg
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
        Plotty.plot "binomial_plot" "Binomial Distribution" curve_


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
            Result.map Data.BinomialRequest (toParams model.numberOfTrials model.p)
                |> andThen (Ok (Just 40))
                |> andThen (Validator.toMaybeInt "PMF" model.pmf)
                |> andThen (Validator.toMaybeInt "CDF" model.cdf)
                |> andThen (Validator.toMaybeIntFromInterval "Sample" 0 101 model.sample)
    in
        case r of
            Ok request ->
                ( { model | stats = RemoteData.Loading }, fetchStats { request | curve = Just (request.params.numberOfTrials + 1) } )

            Err error ->
                ( { model | stats = RemoteData.Failure (Data.BadRequest error) }, drawPlot Nothing )


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


toParams : String -> String -> Result String Data.BinomialParams
toParams n p =
    Result.map2 Data.BinomialParams
        (Validator.toIntFromInterval "NumberOfTrials" 0 201 n)
        (Validator.toNonNegativeFloat "Probability" p)


view : Model -> Html Message
view model =
    let
        response =
            getResponse model
    in
        div [ Attr.class Style.wrapper ]
            [ UI.inputRow "NumberOfTrials" "e.g. 10" ChangeNumberOfTrials
            , UI.inputRow "Probability" "e.g. 0.7" ChangeP
            , viewRemoteStatsData model.stats
            , UI.propertyInputRowWithCaption "Probability mass function (PMF)" "x" ChangePmf response.pmf
            , UI.propertyInputRowWithCaption "Cumulative distribution function (CDF)" "x" ChangeCdf response.cdf
            , UI.propertyInputRowArrayValueWithCaption "Random Sample" "Size" ChangeSample response.sample
            , div [ Attr.id "binomial_plot" ] []
            , UI.submitButton "Retrieve stats" FetchStats
            , UI.error model.stats
            ]


viewRemoteStatsData : RemoteStatsData -> Html Message
viewRemoteStatsData rsd =
    case rsd of
        RemoteData.Success stats ->
            viewStatsData stats

        _ ->
            text ""


viewStatsData : Data.BinomialResponse -> Html Message
viewStatsData response =
    div [ Attr.class Style.propertyCaption ]
        [ UI.propertyRow "Mean" (toString response.mean)
        , UI.propertyRow "StdDev" (toString response.stddev)
        , UI.propertyRow "Variance" (toString response.variance)
        , UI.propertyRow "isNormalApproximationApplicable" (toString response.isNormalApproximationApplicable)
        ]
