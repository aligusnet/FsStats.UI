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


plotLine : String -> String -> Maybe ( Array.Array Float, Array.Array Float ) -> Cmd msg
plotLine plotId title curve =
    case curve of
        Just ( x, y ) ->
            drawPlot { title = title, x = x, y = y, plotId = plotId, plotType = "lines" }

        Nothing ->
            clearPlot plotId
