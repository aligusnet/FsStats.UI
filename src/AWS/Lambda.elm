port module AWS.Lambda exposing (..)

import Data


port fetchStats : Data.Request -> Cmd msg


port fetchStatsSuccess : (String -> msg) -> Sub msg


port fetchStatsError : (String -> msg) -> Sub msg
