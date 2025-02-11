library(shiny)
library(readxl)
library(leaflet)
library(tidygeocoder)
library(dplyr)
library(writexl)

# Définition des identifiants et mots de passe avant d'être utilisés
credentials <- data.frame(
  id = c("admin1", "admin2"),
  pass = c("password1", "password2"),
  stringsAsFactors = FALSE
)

# Charger le fichier Excel
df <- read_excel("Base_de_données.xlsx")

# Vérifier si les colonnes lat et long existent déjà
if (!("lat" %in% colnames(df) && "long" %in% colnames(df))) {
  df <- df %>%
    geocode(address = Adresse, method = "osm")
  write_xlsx(df, "Base_de_données.xlsx")
}

# Fonction pour charger les messages depuis le fichier Excel
load_data <- function() {
  file_name <- "messages.xlsx"
  if (file.exists(file_name)) {
    tryCatch({
      df <- read_excel(file_name)
      return(df)
    }, error = function(e) {
      message("Erreur lors de la lecture du fichier Excel.")
      return(data.frame(Nom = character(), Email = character(), Message = character(), Date = as.POSIXct(character())))
    })
  } else {
    return(data.frame(Nom = character(), Email = character(), Message = character(), Date = as.POSIXct(character())))
  }
}

# Fonction pour sauvegarder les messages dans le fichier Excel
save_data <- function(data) {
  write_xlsx(data, "messages.xlsx")  # Sauvegarde dans un fichier Excel
}

server <- function(input, output, session) {  
  # Variable réactive pour suivre l'état de la connexion
  user_authenticated <- reactiveVal(FALSE)
  
  # Observer l'événement de connexion admin
  observeEvent(input$admin_login, {
    req(input$admin_id, input$admin_pass)  
    
    user <- credentials[credentials$id == input$admin_id & credentials$pass == input$admin_pass, ]
    
    if (nrow(user) == 1) {
      user_authenticated(TRUE)
      output$login_message <- renderText("Connexion réussie. Bienvenue!")
      
      updateTextInput(session, "admin_id", value = "")
      updateTextInput(session, "admin_pass", value = "")
      
      updateTabsetPanel(session, "monOnglet", selected = "Privé")
    } else {
      output$login_message <- renderText("Identifiant ou mot de passe incorrect.")
    }
  })
  
  # Observer l'événement d'ajout d'un membre
  observeEvent(input$add_person, {
    req(input$new_nom, input$new_prenom, input$new_adresse)
    
    new_data <- data.frame(
      Nom = input$new_nom,
      Prénom = input$new_prenom,
      Adresse = input$new_adresse,
      stringsAsFactors = FALSE
    ) %>%
      geocode(address = Adresse, method = "osm")
    
    if (!is.na(new_data$lat) & !is.na(new_data$long)) {
      df <<- bind_rows(df, new_data)
      write_xlsx(df, "Base_de_données.xlsx")
      
      output$add_person_message <- renderText("✅ Membre ajouté avec succès !")
      
      leafletProxy("map") %>%
        clearMarkers() %>%
        addMarkers(
          lng = df$long,
          lat = df$lat,
          popup = paste0(
            "<b>📌 Nom :</b> ", df$Nom, "<br>",
            "<b>🙍 Prénom :</b> ", df$Prénom, "<br>",
            "<b>📍 Adresse :</b> ", df$Adresse
          )
        )
    } else {
      output$add_person_message <- renderText("⚠️ Impossible de géocoder cette adresse.")
    }
  })
  
  # Interface dynamique pour l'onglet privé
  output$private_panel <- renderUI({
    if (user_authenticated()) {
      fluidPage(
        titlePanel("Carte"),
        wellPanel(
          textInput("new_nom", "Nom :", ""),
          textInput("new_prenom", "Prénom :", ""),
          textInput("new_adresse", "Adresse :", ""),
          actionButton("add_person", "Ajouter un membre", class = "btn btn-success")
        ),
        leafletOutput("map", height = "600px"),
        textOutput("add_person_message")
      )
    } else {
      fluidPage(
        tags$h3("Espace Privé"),
        tags$p("Veuillez vous connecter pour accéder à cet espace.")
      )
    }
  })
  
  # Affichage de la carte
  output$map <- renderLeaflet({
    leaflet(df) %>%
      addTiles() %>%
      addMarkers(
        lng = ~long,
        lat = ~lat,
        popup = ~paste0(
          "<b>📌 Nom :</b> ", df$Nom, "<br>",
          "<b>🙍 Prénom :</b> ", df$Prénom, "<br>",
          "<b>📍 Adresse :</b> ", df$Adresse
        )
      )
  })
  
  # Mise à jour des marqueurs en cas de sélection d'une personne
  observeEvent(input$selected_person, {
    selected_data <- df[df$Nom == input$selected_person, ]
    
    if (nrow(selected_data) > 0) {
      leafletProxy("map") %>%
        clearMarkers() %>%
        addMarkers(
          lng = selected_data$long,
          lat = selected_data$lat,
          popup = paste0(
            "<b>📌 Nom :</b> ", selected_data$Nom, "<br>",
            "<b>🙍 Prénom :</b> ", selected_data$Prénom, "<br>",
            "<b>📍 Adresse :</b> ", selected_data$Adresse
          )
        )
    }
  })
  
  # Rediriger vers l'onglet "Contact" lorsque le bouton "Commencer" est cliqué
  observeEvent(input$start, {
    updateTabsetPanel(session, "monOnglet", selected = "Contact")
  })
  
  # Téléchargement du fichier PDF
  output$pdfDownload <- downloadHandler(
    filename = function() { "Gestion_de_projet.pdf" },
    content = function(file) { file.copy("Gestion_de_projet.pdf", file) }
  )
  
  # Charger les messages existants
  df_messages <- load_data()
}

