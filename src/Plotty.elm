port module Plotty exposing (..)

import Array exposing (Array)


type alias Arguments =
    { title : String
    , x : Array Float
    , y : Array Float
    , plotId : String
    }


port drawPlot : Arguments -> Cmd msg


port clearPlot : String -> Cmd msg


plot : String -> String -> Maybe ( Array.Array Float, Array.Array Float ) -> Cmd msg
plot plotId title curve =
    case curve of
        Just ( x, y ) ->
            drawPlot { title = title, x = x, y = y, plotId = plotId }

        Nothing ->
            clearPlot plotId
