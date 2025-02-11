library(shiny)
library(readxl)
library(leaflet)
library(tidygeocoder)
library(dplyr)
library(writexl)

server <- function(input, output, session) {
  # Charger les données
  df <- read_excel("Base_de_données.xlsx", sheet = 1) %>% as.data.frame()
  
  # Vérifier et ajouter lat/long si elles n'existent pas
  if (!("lat" %in% colnames(df) && "long" %in% colnames(df))) {
    df <- df %>% geocode(address = Adresse, method = "osm")
    writexl::write_xlsx(df, "Base_de_données.xlsx")  # Sauvegarde avec coordonnées
  }
  
  # Mettre à jour la liste déroulante avec les noms des personnes
  observe({
    updateSelectInput(session, "nom_selectionne", 
                      choices = unique(paste(df$Prénom, df$Nom, sep = " ")))
  })
  
  # Réinitialiser la carte en supprimant tous les marqueurs
  observeEvent(input$reset_map, {
    leafletProxy("map") %>% clearMarkers()
  })
  
  # Observer la sélection et mettre à jour la carte
  observeEvent(input$nom_selectionne, {
    selected_person <- df %>%
      filter(paste(Prénom, Nom, sep = " ") == input$nom_selectionne)
    
    if (nrow(selected_person) > 0) {
      leafletProxy("map") %>%
        clearMarkers() %>%
        addMarkers(
          lng = selected_person$long, lat = selected_person$lat, 
          popup = paste0("<b>📌 Nom :</b> ", selected_person$Nom, "<br>",
                         "<b>🙍 Prénom :</b> ", selected_person$Prénom, "<br>",
                         "<b>📍 Adresse :</b> ", selected_person$Adresse)
        )
    }
  })
  
  # Affichage initial de la carte avec tous les marqueurs
  output$map <- renderLeaflet({
    leaflet(df) %>%
      addTiles() %>%
      addMarkers(lng = ~long, lat = ~lat, 
                 popup = ~paste0("<b>📌 Nom :</b> ", Nom, "<br>",
                                 "<b>🙍 Prénom :</b> ", Prénom, "<br>",
                                 "<b>📍 Adresse :</b> ", Adresse))
  })
}
