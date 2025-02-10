library(shiny)
library(readxl)
library(leaflet)
library(tidygeocoder)
library(dplyr)
library(writexl)

server <- function(input, output, session) {
  # Création d'un objet réactif pour stocker les marqueurs
  markers <- reactiveVal(data.frame(lng = numeric(), lat = numeric()))
  
  # Ajouter un marqueur
  observeEvent(input$add_marker, {
    new_marker <- data.frame(lng = input$longitude, lat = input$latitude)
    markers(rbind(markers(), new_marker))  # Ajout du nouveau marqueur
  })
  
  # Réinitialiser la carte (supprimer tous les marqueurs)
  observeEvent(input$reset_map, {
    markers(data.frame(lng = numeric(), lat = numeric()))  # Réinitialisation des marqueurs
  })
  
  #Affichage de la carte
  output$map <- renderLeaflet({
    leaflet() %>%
    addTiles() %>%
      setView(lng = 2.3522, lat = 48.8566, zoom = 6)
  })
  
  # Mise à jour des marqueurs
  observe({
    leafletProxy("map") %>%
      clearMarkers() %>%
      addMarkers(data = markers(), ~lng, ~lat, popup = "Nouveau point")
  })
}

