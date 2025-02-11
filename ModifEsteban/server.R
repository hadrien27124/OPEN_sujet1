library(shiny)
library(readxl)
library(leaflet)
library(tidygeocoder)
library(dplyr)
library(writexl)

# Chemin du fichier Excel
file_path <- "Base_de_données.xlsx"

# Charger la base de données
df <- read_excel(file_path)

# Vérifier si les colonnes lat et long existent déjà, sinon les créer
if (!("lat" %in% colnames(df) && "long" %in% colnames(df))) {
  df <- df %>%
    geocode(address = Adresse, method = "osm")
  
  # Sauvegarder les données mises à jour
  write_xlsx(df, file_path)
}

server <- function(input, output, session) {
  # Stocker les données en mode réactif
  data <- reactiveVal(df)
  
  # Ajouter un membre et mettre à jour la base de données
  observeEvent(input$add_member, {
    if (input$nom != "" && input$prenom != "" && input$adresse != "") {
      new_entry <- data.frame(
        Nom = input$nom,
        Prénom = input$prenom,
        Adresse = input$adresse
      )
      
      # Géocodage de l'adresse
      new_entry <- new_entry %>%
        geocode(address = Adresse, method = "osm")
      
      # Vérifier si le géocodage a réussi
      if (!is.na(new_entry$lat) && !is.na(new_entry$long)) {
        updated_data <- rbind(data(), new_entry)
        data(updated_data)
        
        # Sauvegarder les nouvelles données dans l'Excel
        write_xlsx(updated_data, file_path)
        
        showNotification("✅ Membre ajouté avec succès !", type = "message")
      } else {
        showNotification("⚠️ Adresse introuvable.", type = "error")
      }
    } else {
      showNotification("⚠️ Tous les champs doivent être remplis.", type = "error")
    }
  })
  
  # Gérer l'ajout manuel de marqueurs
  markers <- reactiveVal(data.frame(lng = numeric(), lat = numeric()))
  
  observeEvent(input$add_marker, {
    new_marker <- data.frame(lng = input$longitude, lat = input$latitude)
    markers(rbind(markers(), new_marker))
  })
  
  observeEvent(input$reset_map, {
    markers(data.frame(lng = numeric(), lat = numeric()))
  })
  
  # Affichage de la carte
  output$map <- renderLeaflet({
    leaflet(data()) %>%
      addTiles() %>%
      addMarkers(
        lng = ~long, 
        lat = ~lat, 
        popup = ~paste0(
          "<b>📌 Nom :</b> ", Nom, "<br>",
          "<b>🙍 Prénom :</b> ", Prénom, "<br>",
          "<b>📍 Adresse :</b> ", Adresse
        )
      )
  })
  
  # Mise à jour dynamique de la carte
  observe({
    leafletProxy("map") %>%
      clearMarkers() %>%
      addMarkers(data = data(), lng = ~long, lat = ~lat, popup = ~paste0(
        "<b>📌 Nom :</b> ", Nom, "<br>",
        "<b>🙍 Prénom :</b> ", Prénom, "<br>",
        "<b>📍 Adresse :</b> ", Adresse
      )) %>%
      addMarkers(data = markers(), lng = ~lng, lat = ~lat, popup = "Marqueur manuel")
  })
}
