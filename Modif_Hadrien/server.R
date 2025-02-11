library(shiny)
library(readxl)
library(leaflet)
library(tidygeocoder)
library(dplyr)
library(writexl)
library(readr)

# Charger le fichier Excel
df <- read_excel("Base_de_données.xlsx")

# Vérifier si les colonnes lat et long existent déjà
if (!("lat" %in% colnames(df) && "long" %in% colnames(df))) {
  # Géocodage uniquement si les colonnes n'existent pas
  df <- df %>%
    geocode(address = Adresse, method = "osm")
  
  # Sauvegarder le dataframe mis à jour avec lat et long dans le fichier Excel
  write_xlsx(df, "Base_de_données.xlsx")
}

# Vérifier les noms des colonnes pour s'assurer que lat et long ont été ajoutées
# print(colnames(df))


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
    
    observeEvent(input$send, {
      if (input$name == "Nom" || input$email == "email" || input$message == "message") {
        output$confirm <- renderText("⚠️ Veuillez remplir tous les champs.")
      } else {
        
        # Créer un dataframe avec le message
        new_message <- data.frame(
          Nom = input$name,
          Email = input$email,
          Message = input$message,
          Date = Sys.time(),
          stringsAsFactors = FALSE
        )
        
        # Vérifier si le fichier existe déjà
        file_name <- "messages.csv"
        
        if (file.exists(file_name)) {
          old_messages <- read_csv(file_name, show_col_types = FALSE)
          all_messages <- bind_rows(old_messages, new_message)
        } else {
          all_messages <- new_message
        }
        
        # Sauvegarder correctement le fichier CSV (éviter d'avoir tout dans une seule colonne)
        write.csv(all_messages, file_name, row.names = FALSE, fileEncoding = "UTF-8")
        
        output$confirm <- renderText("✅ Message envoyé avec succès !")
        
        # 🔹 Optionnel : Envoi par email (décommente si nécessaire)
        # send.mail(from = "ton_email@gmail.com",
        #           to = "destinataire@gmail.com",
        #           subject = paste("Nouveau message de", input$name),
        #           body = paste("Email :", input$email, "\n\nMessage :", input$message),
        #           smtp = list(host.name = "smtp.gmail.com", port = 465, user.name = "ton_email@gmail.com", passwd = "ton_mot_de_passe", ssl = TRUE),
        #           authenticate = TRUE,
        #           send = TRUE)
      }
    })
  })}
