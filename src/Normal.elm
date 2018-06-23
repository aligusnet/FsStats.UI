module Normal exposing (main)

import Array
import Html exposing (..)
import Html.Attributes as Attr
import RemoteData
import Data
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
    RemoteData.RemoteData Data.Error Data.NormalResponse


type alias Model =
    { stats : RemoteStatsData
    , mu : String
    , sigma : String
    , pdf : String
    , cdf : String
    , quantile : String
    , sample : String
    }


type Message
    = FetchStats
    | FetchStatsSuccess String
    | FetchStatsError String
    | ChangeMu String
    | ChangeSigma String
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


getResponse : Model -> Data.NormalResponse
getResponse model =
    case model.stats of
        RemoteData.Success stats ->
            stats

        _ ->
            Data.emptyNormalResponse


init : ( Model, Cmd Message )
init =
    ( { stats = RemoteData.NotAsked
      , mu = ""
      , sigma = ""
      , pdf = ""
      , cdf = ""
      , quantile = ""
      , sample = ""
      }
    , Cmd.none
    )


fetchStats : Data.NormalRequest -> Cmd msg
fetchStats request =
    AWS.Lambda.fetchStats { normal = Just request }


drawPlot : Maybe ( Array.Array Float, Array.Array Float ) -> Cmd msg
drawPlot curve =
    Plotty.plot "normal_plot" "Normal Distribution" curve


update : Message -> Model -> ( Model, Cmd Message )
update msg model =
    case msg of
        FetchStats ->
            validateAndFetchStats model

        FetchStatsSuccess value ->
            case Json.decodeResponse value of
                Ok response ->
                    case response.normal of
                        Just normal ->
                            ( { model | stats = RemoteData.Success normal }, drawPlot normal.curve )

                        Nothing ->
                            ( { model | stats = RemoteData.Failure (Data.BadPayload "No data retrieved") }, drawPlot Nothing )

                Err error ->
                    ( { model | stats = RemoteData.Failure (Data.BadPayload error) }, drawPlot Nothing )

        FetchStatsError error ->
            ( { model | stats = RemoteData.Failure (Data.BadStatus error) }, drawPlot Nothing )

        ChangeMu value ->
            ( { model | mu = value }, Cmd.none )

        ChangeSigma value ->
            ( { model | sigma = value }, Cmd.none )

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
            Result.map Data.NormalRequest (toNormalParams model.mu model.sigma)
                |> andThen (Ok (Just 40))
                |> andThen (Validator.toMaybeFloat "PDF" model.pdf)
                |> andThen (Validator.toMaybeFloat "CDF" model.cdf)
                |> andThen (Validator.toMaybeFloatFromInterval "Quantile" 0 1 model.quantile)
                |> andThen (Validator.toMaybeIntFromInterval "Sample" 1 100 model.sample)
    in
        case r of
            Ok request ->
                ( { model | stats = RemoteData.Loading }, fetchStats request )

            Err error ->
                ( { model | stats = RemoteData.Failure (Data.BadRequest error) }, drawPlot Nothing )


toNormalParams : String -> String -> Result String Data.NormalParams
toNormalParams mu sigma =
    Result.map2 Data.NormalParams (Validator.toFloat "Mu" mu) (Validator.toNonNegativeFloat "Sigma" sigma)


view : Model -> Html Message
view model =
    let
        response =
            getResponse model
    in
        div [ Attr.class Style.wrapper ]
            [ UI.caption "Normal Distribution"
            , UI.inputRow "Mu" "mu, e.g. 0.0" ChangeMu
            , UI.inputRow "Sigma" "sigma, e.g. 1.0" ChangeSigma
            , viewRemoteStatsData model.stats
            , UI.propertyInputRowWithCaption "Probability density function (PDF)" "x" ChangePdf response.pdf
            , UI.propertyInputRowWithCaption "Cumulative distribution function (CDF)" "x" ChangeCdf response.cdf
            , UI.propertyInputRowWithCaption "Quantile" "F" ChangeQuantile response.quantile
            , UI.propertyInputRowArrayValueWithCaption "Random Sample" "Size" ChangeSample response.sample
            , div [ Attr.id "normal_plot" ] []
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


viewStatsData : Data.NormalResponse -> Html Message
viewStatsData response =
    div [ Attr.class Style.propertyCaption ]
        [ UI.propertyRow "Mean" (toString response.mean)
        , UI.propertyRow "StdDev" (toString response.stddev)
        , UI.propertyRow "Variance" (toString response.variance)
        ]
