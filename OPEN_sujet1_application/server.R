library(shiny)
library(readxl)
library(leaflet)
library(tidygeocoder)
library(dplyr)
library(writexl)


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
  })
  
  # Rediriger vers l'onglet "Contact" lorsque le bouton "Commencer" est cliqué
  observeEvent(input$start, {
    updateTabsetPanel(session, "monOnglet", selected = "Contact")
  })
  
  # Téléchargement du fichier PDF
  output$pdfDownload <- downloadHandler(
    filename = function() { 
      paste("Gestion_de_projet.pdf") 
    },
    content = function(file) {
      # Placez votre chemin de fichier PDF ici
      file.copy("Gestion_de_projet.pdf", file)
    }
  )
  
  # Charger les données existantes depuis le fichier Excel
  df_messages <- load_data()
  
  observeEvent(input$send, {
    if (input$name == "" || input$email == "" || input$message == "") {
      showModal(modalDialog(
        title = "Erreur ⚠️",
        "Veuillez remplir tous les champs avant d'envoyer le message.",
        easyClose = TRUE,
        footer = modalButton("OK")
      ))
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
      
      
      # Réinitialisation des champs du formulaire
      updateTextInput(session, "name", value = "")
      updateTextInput(session, "email", value = "")
      updateTextAreaInput(session, "message", value = "")
      
      showModal(modalDialog(
        title = "Message envoyé ✅",
        "Votre message a bien été envoyé. Nous vous répondrons bientôt !",
        easyClose = TRUE,
        footer = modalButton("OK") 
      ))
    }
  })
}


