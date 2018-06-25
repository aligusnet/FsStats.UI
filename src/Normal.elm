module Normal exposing (main)

import Array exposing (Array)
import Html exposing (..)
import Html.Attributes as Attr
import RemoteData
import Data exposing (emptyRequest)
import Data.Json as Json
import AWS.Lambda
import Plotty
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
    Data.NormalResponse


type alias RemoteStatsData =
    RemoteData.RemoteData Data.Error Response


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


getResponse : Model -> Response
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
    AWS.Lambda.fetchStats { emptyRequest | normal = Just request }


drawPlot : Maybe ( Array.Array Float, Array.Array Float ) -> Cmd msg
drawPlot curve =
    Plotty.plot "normal_plot" "Normal Distribution" curve


update : Message -> Model -> ( Model, Cmd Message )
update msg model =
    case msg of
        FetchStats ->
            validateAndFetchStats model

        FetchStatsSuccess value ->
            onFetchStatsSuccess model value

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
                |> andThen (Validator.toMaybeIntFromInterval "Sample" 0 101 model.sample)
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
            case response.normal of
                Just normal ->
                    ( { model | stats = RemoteData.Success normal }, drawPlot normal.curve )

                Nothing ->
                    ( { model | stats = RemoteData.Failure (Data.BadPayload "No data retrieved") }, drawPlot Nothing )

        Err error ->
            ( { model | stats = RemoteData.Failure (Data.BadPayload error) }, drawPlot Nothing )


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
            [ UI.Property.render propertyMu
            , UI.Property.render propertySigma
            , viewRemoteStatsData model.stats
            , UI.Property.render (propertyPdf response)
            , UI.Property.render (propertyCdf response)
            , UI.Property.render (propertyQuantile response)
            , UI.Property.render (propertySample response)
            , div [ Attr.id "normal_plot" ] []
            , UI.submitButton "Retrieve stats" FetchStats
            , UI.error model.stats
            ]


propertyMu : Property Message
propertyMu =
    { property
        | name = "Mu"
        , message = Just ChangeMu
        , placeholder = "mu, e.g. 0.0"
    }


propertySigma : Property Message
propertySigma =
    { property
        | name = "Sigma"
        , message = Just ChangeSigma
        , placeholder = "sigma, e.g. 1.0"
    }


propertyPdf : Response -> Property Message
propertyPdf response =
    { property
        | caption = Just "Probability density function (PDF)"
        , name = "x"
        , message = Just ChangePdf
        , value = UI.Property.VFloat response.pdf
    }


propertyCdf : Response -> Property Message
propertyCdf response =
    { property
        | caption = Just "Cumulative distribution function (CDF)"
        , name = "x"
        , message = Just ChangeCdf
        , value = UI.Property.VFloat response.cdf
    }


propertyQuantile : Response -> Property Message
propertyQuantile response =
    { property
        | caption = Just "Quantile"
        , name = "F"
        , message = Just ChangeQuantile
        , value = UI.Property.VFloat response.quantile
    }


propertySample : Response -> UI.Property.Property Message
propertySample response =
    { property
        | caption = Just "Random Sample"
        , name = "Size"
        , message = Just ChangeSample
        , value = UI.Property.VArrayFloat response.sample
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
    in
        div []
            [ UI.Property.render (makeProperty "Mean" .mean)
            , UI.Property.render (makeProperty "StdDev" .stddev)
            , UI.Property.render (makeProperty "Variance" .variance)
            ]
