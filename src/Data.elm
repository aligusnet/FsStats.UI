module Data exposing (..)

import Data.Normal as Normal
import Data.Bernoulli as Bernoulli
import Data.Binomial as Binomial
import Data.Poisson as Poisson
import Data.Students as Students
import Data.SummaryStatistics as SummaryStatistics
import Data.OnePopulationMeanTest as OnePopulationMeanTest


type alias Request =
    { normal : Maybe Normal.Request
    , bernoulli : Maybe Bernoulli.Request
    , binomial : Maybe Binomial.Request
    , poisson : Maybe Poisson.Request
    , students : Maybe Students.Request
    , summary : Maybe SummaryStatistics.Request
    , onePopulationMeanTest : Maybe OnePopulationMeanTest.Request
    }


emptyRequest : Request
emptyRequest =
    { normal = Nothing
    , bernoulli = Nothing
    , binomial = Nothing
    , poisson = Nothing
    , students = Nothing
    , summary = Nothing
    , onePopulationMeanTest = Nothing
    }


type alias Response =
    { normal : Maybe Normal.Response
    , bernoulli : Maybe Bernoulli.Response
    , binomial : Maybe Binomial.Response
    , poisson : Maybe Poisson.Response
    , students : Maybe Students.Response
    , summary : Maybe SummaryStatistics.Response
    , onePopulationMeanTest : Maybe OnePopulationMeanTest.Response
    , errorType : Maybe String
    , errorMessage : Maybe String
    }


type Error
    = BadStatus String
    | BadPayload String
    | BadRequest String
    | UnexpectedResponse Response
