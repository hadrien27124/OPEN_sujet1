library(shiny)
library(readxl)
library(leaflet)
library(tidygeocoder)
library(dplyr)
library(writexl)
library(readr)

# Charger le fichier Excel de données géographiques
df <- read_excel("Base_de_données.xlsx")

# Vérifier si les colonnes lat et long existent déjà
if (!("lat" %in% colnames(df) && "long" %in% colnames(df))) {
  # Géocodage uniquement si les colonnes n'existent pas
  df <- df %>%
    geocode(address = Adresse, method = "osm")
  
  # Sauvegarder le dataframe mis à jour avec lat et long dans le fichier Excel
  write_xlsx(df, "Base_de_données.xlsx")
}

# Fonction pour charger les messages depuis le fichier Excel
load_data <- function() {
  file_name <- "messages.xlsx"
  
  if (file.exists(file_name)) {
    # Essayer de lire le fichier Excel
    tryCatch({
      df <- read_excel(file_name)
      return(df)
    }, error = function(e) {
      # Si une erreur survient lors de la lecture du fichier, on renvoie un dataframe vide
      message("Erreur lors de la lecture du fichier Excel.")
      return(data.frame(Nom = character(), Email = character(), Message = character(), Date = as.POSIXct(character())))
    })
  } else {
    # Si le fichier n'existe pas, créer un dataframe vide avec les colonnes appropriées
    return(data.frame(Nom = character(), Email = character(), Message = character(), Date = as.POSIXct(character())))
  }
}

# Fonction pour sauvegarder les messages dans le fichier Excel
save_data <- function(data) {
  write_xlsx(data, "messages.xlsx")  # Sauvegarde dans un fichier Excel
}

# Serveur Shiny
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
  
  # Affichage de la carte
  output$map <- renderLeaflet({
    leaflet(df) %>%
      addTiles() %>%  # Fond de carte
      addMarkers(
        lng = ~long,  # Coordonnée longitude
        lat = ~lat,   # Coordonnée latitude
        popup = ~paste0(
          "<b>📌 Nom :</b> ", df$Nom, "<br>",
          "<b>🙍 Prénom :</b> ", df$Prénom, "<br>",
          "<b>📍 Adresse :</b> ", df$Adresse ))
  })
  
  # Mise à jour des marqueurs
  observe({
    leafletProxy("map") %>%
      clearMarkers() %>%
      addMarkers(data = markers(), ~lng, ~lat, popup = "Nouveau point")
    
    # Charger les données existantes depuis le fichier Excel
    df_messages <- load_data()
    
    observeEvent(input$send, {
      if (input$name == "" || input$email == "" || input$message == "") {
        output$confirm <- renderText("⚠️ Veuillez remplir tous les champs.")
      } else {
        # Créer un dataframe avec des colonnes distinctes
        new_message <- data.frame(
          Nom = input$name,
          Email = input$email,
          Message = input$message,
          Date = Sys.time(),  # Ajoute la date de l'envoi
          stringsAsFactors = FALSE
        )
        
        # Si le fichier Excel existe, on lit les anciens messages et on ajoute le nouveau
        if (file.exists("messages.xlsx")) {
          # Lire le fichier Excel existant
          old_messages <- read_excel("messages.xlsx")
          
          # Convertir les colonnes en types compatibles avant de les combiner
          old_messages$Nom <- as.character(old_messages$Nom)
          old_messages$Email <- as.character(old_messages$Email)
          old_messages$Message <- as.character(old_messages$Message)
          old_messages$Date <- as.POSIXct(old_messages$Date)
          
          # Ajouter les nouvelles données au dataframe existant
          all_messages <- bind_rows(old_messages, new_message)  # Ajouter la nouvelle ligne
        } else {
          # Si le fichier n'existe pas, on crée un dataframe avec le nouveau message
          all_messages <- new_message
        }
        
        # Sauvegarder le fichier Excel avec les colonnes distinctes
        save_data(all_messages)  # Sauvegarder dans le fichier Excel
        
        # Message de confirmation
        output$confirm <- renderText("✅ Message envoyé avec succès !")
      }
    })
  })
}