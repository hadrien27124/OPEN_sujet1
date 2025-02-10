library(shiny)
library(readxl)
library(leaflet)
library(tidygeocoder)
library(dplyr)

ui <- fluidPage(
  titlePanel("Carte"),
  leafletOutput("map")
)
