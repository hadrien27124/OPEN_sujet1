library(shiny)
library(leaflet)

ui <- fluidPage(
  titlePanel("Carte"),
  leafletOutput("map")
)
