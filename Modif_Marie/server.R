library(shiny)
library(readxl)
library(leaflet)
library(tidygeocoder)
library(dplyr)
library(writexl)

server <- function(input, output, session) {
  output$map <- renderLeaflet({
    leaflet() %>%
    addTiles() %>%
      setView(lng = 2.3522, lat = 48.8566, zoom = 6) %>%  
      addMarkers(lng = 2.3522, lat = 48.8566, popup = "Paris")
    
  })
}

