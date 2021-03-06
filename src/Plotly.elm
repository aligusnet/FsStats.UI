port module Plotly exposing (..)

import Array exposing (Array)


type alias Arguments =
    { title : String
    , x : Array Float
    , y : Array Float
    , plotId : String
    , plotType : String
    }


port drawPlot : Arguments -> Cmd msg


port clearPlot : String -> Cmd msg


plotLine : String -> String -> Maybe ( Array Float, Array Float ) -> Cmd msg
plotLine plotId title curve =
    case curve of
        Just ( x, y ) ->
            drawPlot { title = title, x = x, y = y, plotId = plotId, plotType = "lines" }

        Nothing ->
            clearPlot plotId


plotBar : String -> String -> Maybe ( Array Float, Array Float ) -> Cmd msg
plotBar plotId title xy =
    case xy of
        Just ( x, y ) ->
            drawPlot { title = title, x = x, y = y, plotId = plotId, plotType = "bar" }

        Nothing ->
            clearPlot plotId


plotHistogram : String -> String -> Maybe (Array Float) -> Cmd msg
plotHistogram plotId title data =
    case data of
        Just x ->
            drawPlot { title = title, x = x, y = Array.empty, plotId = plotId, plotType = "histogram" }

        Nothing ->
            clearPlot plotId
