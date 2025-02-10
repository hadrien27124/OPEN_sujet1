library(shiny)
library(leaflet)

ui <- fluidPage(
  titlePanel("Carte des Associations en France"),

  # Affichage de la carte Leaflet
  leafletOutput("map", height = "700px")
)

 