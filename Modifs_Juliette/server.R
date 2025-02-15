library(shiny)
library(readxl)
library(leaflet)
library(tidygeocoder)
library(dplyr)
library(writexl)
library(rsconnect)



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
  #Observer l'évènement de clic sur le bouton "En savoir plus" et ouvrir le pdf gestion de projet dans l'app
  observeEvent(input$showPDF, {
    showModal(modalDialog(
      title = tags$span("En Savoir plus - Répartition des associations en France", style="font-family: Explora; font-size: 20px; color: #1f5014"),
      size = "l",  # Grande taille pour la modale
      easyClose = TRUE,  # Permet de fermer facilement la modale
      footer = NULL,  # Pas de pied de page
      tags$div(
        # Utilisation d'un iframe pour afficher le PDF
        tags$iframe(src = "Gestion_de_projet.pdf", width = "100%", height = "500px")
      )
    ))
  })
  
  
  observeEvent(input$credits, {
    showModal(modalDialog(
      title = tags$div("Crédits", style="font-family: Explora; font-size: 25px; color: #1f5014"),
      style="font-family: Achieve; font-size: 13px; font-weight: bold; color: black",
      size = "l",  # Taille de la fenêtre
      easyClose = TRUE,  # Fermeture du modale en cliquant en dehors
      footer = NULL,  # Pas de pied de page
      tags$div(
        # Contenu des crédits : texte, liens, etc.
        h4("Développé par des étudiants en 4ème année de l'ISARA-Lyon", style = "font-family: ContrailOne; font-size: 22px; color: #4b8644;"),
        p("Ce projet a été réalisé dans le cadre d'un module de perfectionnement en informatique par : ", 
          tags$b("Hadrien Schmitt"), ", ", tags$b("Esteban Faravellon"), ", ", 
          tags$b("Sofiane Bouhamou"), ", ", tags$b("Clara Couston"), ", ", 
          tags$b("Juliette Goudaert"), " et ", tags$b("Marie Sanchez"), "."),
        tags$br(),
        p("Les tâches ont été réparties de la manière suivante :"),
        tags$ul(
          tags$li(p(tags$b(tags$u("Hadrien")), " : Implémentation de la carte intéractive, mise en place de l'onglet Contact avec son fonctionnement (formulaire et conditions de remplissage), mise en place des fonctionnalités de l'onglet Administrateurs avec la déconnection des membres via un bouton.")),
          tags$li(p(tags$b(tags$u("Clara")), " : Implémentation de la base de données (nom, prénom et adresse) avec géocodage en coordonnées pour affichage sur la carte, mise en place de l'onglet présentation avec texte et boutons.")),
          tags$li(p(tags$b(tags$u("Esteban")), " : Mise en place des boutons pop-up avec affichage des informations sur les personnes, mise en place de la fonctionnalité de la carte avec l'ajout des personnes dans l'onglet administrateur.")),
          tags$li(p(tags$b(tags$u("Marie")), " : Mise en place des différents onglets de l'interface avec les styles. Mise en place de l'onglet Administrateur avec le blocage d'accès avec identifiant et mot de passe.")),
          tags$li(p(tags$b(tags$u("Sofiane")), " : Mise en place de l'onglet Carte avec la liste déroulante et la réinitialisation des données sur la carte.")),
          tags$li(p(tags$b(tags$u("Juliette")), " : Mise en place du design général de l'application et de l'esthétisme de l'interface, fonctionnalité du bouton en savoir plus, crédits dans l'onglet Contact."))),
        p("L'ensemble des membres ont contribué à la mise à jour et aux avancées de l'interface via l'outil GitHub."),
      )
    )
    )
  }
  )
  
  # Liste des identifiants et mots de passe autorisés
  credentials <- data.frame(
    id = c("admin1", "admin2"),
    pass = c("password1", "password2"),
    stringsAsFactors = FALSE
  )
  
  # Variable réactive pour suivre l'état de la connexion
  user_authenticated <- reactiveVal(FALSE)  # Par défaut, non authentifié
  
  # Observer l'événement de clic sur le bouton de connexion
  observeEvent(input$admin_login, {
    req(input$admin_id, input$admin_pass)  # S'assurer que les champs ne sont pas vides
    
    # Vérifier si les informations d'identification sont correctes
    user <- credentials[credentials$id == input$admin_id & credentials$pass == input$admin_pass, ]
    
    if (nrow(user) == 1) {
      user_authenticated(TRUE)
      output$login_message <- renderText("Connexion réussie. Bienvenue!")
      
      updateTextInput(session, "admin_id", value = "")
      updateTextInput(session, "admin_pass", value = "")
      
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
  
  
  output$private_mdp <- renderUI({
    if (user_authenticated()) {
      fluidPage(
        actionButton("logout", "Déconnexion", 
                     style="background-color: red; color: white; font-family: Explora; font-weight: bold; border-radius: 5px; padding: 10px 20px; border: none;float:right;"),
        br(""),
        titlePanel("Carte"),
        wellPanel(
          textInput("new_nom", "Nom :", ""),
          textInput("new_prenom", "Prénom :", ""),
          textInput("new_adresse", "Adresse :", ""),
          actionButton("add_person", "Ajouter un membre", class = "btn btn-success", style="font-family: Explora; background-color: #4b8644")
        ),
        leafletOutput("map", height = "600px"),
        textOutput("add_person_message")
        
      )
    } else {
      fluidPage(
        textInput("admin_id", "Identifiant :", ""),
        passwordInput("admin_pass", "Mot de passe :"),
        actionButton("admin_login", "Se connecter", 
                     style = "font-family: Explora; margin-top: 10px; background-color: #4b8644; color: white; font-weight: bold; border-radius: 5px; padding: 10px 20px; border: none;"
        ),
        textOutput("login_message")
      )
    }
  })
  
  observeEvent(input$logout, {
    user_authenticated(FALSE)  # Déconnecte l'utilisateur
    output$login_message <- renderText("Vous avez été déconnecté.")  # Message de confirmation
  })
  
  
  # Rendre l'interface privée visible une fois l'utilisateur authentifié
  output$private_panel <- renderUI({
    if (user_authenticated()) {
      fluidPage(
       
      )
    } else {
      fluidPage(
        tags$p("Veuillez vous connecter pour accéder à cet espace.")
      )
    }
  })
  
  # Création d'un objet réactif pour stocker les marqueurs
  markers <- reactiveVal(data.frame(lng = numeric(), lat = numeric()))
  
  # Ajouter un marqueur
  observeEvent(input$add_marker, {
    new_marker <- data.frame(lng = input$longitude, lat = input$latitude)
    markers(rbind(markers(), new_marker))  # Ajout du nouveau marqueur
  })
  
  # Réinitialiser la carte (afficher tous les marqueurs avec leurs coordonnées)
  observeEvent(input$reset_map, {
    # Effacer les marqueurs existants
    leafletProxy("map") %>%
      clearMarkers() %>%
      addMarkers(data = df, 
                 lng = ~long, 
                 lat = ~lat, 
                 popup = ~paste0(
                   "<b>📌 Nom :</b> ", df$Nom, "<br>",
                   "<b>🙍 Prénom :</b> ", df$Prénom, "<br>",
                   "<b>📍 Adresse :</b> ", df$Adresse, "<br>",
                   "<b>📍 Coordonnée Longitude :</b> ", df$long, "<br>",
                   "<b>📍 Coordonnée Latitude :</b> ", df$lat
                 ))
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
  
  is_valid_email <- function(email) {
    grepl("^[[:alnum:]._%+-]+@[[:alnum:]-]+\\.[[:alpha:]]{2,}$", email)
  }
  
  observeEvent(input$send, {
    if (input$name == "" || input$email == "" || input$message == "") {
      showModal(modalDialog(
        title = "Erreur ⚠️",
        "Veuillez remplir tous les champs avant d'envoyer le message.",
        easyClose = TRUE,
        footer = modalButton("OK")
      ))
    } else if (!is_valid_email(input$email)) {  # Vérifie l'e-mail
      showModal(modalDialog(
        title = "Adresse e-mail invalide ❌",
        "Veuillez entrer une adresse e-mail valide (ex: exemple@isara.com).",
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