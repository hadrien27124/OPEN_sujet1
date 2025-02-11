library(shiny)
library(readxl)
library(leaflet)
library(tidygeocoder)
library(dplyr)

ui <- fluidPage(
  
  # Modification de la police et du style des onglets
  tags$style(HTML("
    /* Modifier la barre d'onglets */
    .nav-tabs > li > a {
        font-family: 'Roboto';
        font-size: 18px;
        font-weight: bold;
        color: white;
        background-color: darkgray;
        border-radius: 10px 10px 0 0;
        padding: 10px 20px;
    }

    /* Modifier l'onglet actif (FORCÉ en vert) */
    .nav-tabs > li.active > a {
      background-color: mediumseagreen !important;
      color: white !important;
      border-bottom: 3px solid red !important;
    }

    /* Modifier l'onglet en survolant */
    .nav-tabs > li > a:hover {
        background-color: lightgray;
        color: black;
    }

    /* Modifier la barre de fond et l'ombre des onglets */
    .nav-tabs {
        border-bottom: 2px solid #ccc; /* bordure en bas */
    }
    
    .nav-tabs > li > a {
        border: 1px solid #ccc; /* contour fin */
        box-shadow: 2px 2px 5px rgba(0,0,0,0.1); /* Ajoute une ombre */
    }
    
    /* Arrière-plan de l'application */
    body {
        background-color: #f5f5f5; /* Gris clair */
    }
    
    /* Contenu des onglets avec bordure et ombre */
    .tab-content {
        background-color: white;
        padding: 20px;
        border-radius: 10px;
        box-shadow: 2px 2px 10px rgba(0,0,0,0.1); /* Ombre */
        margin-top: 10px;
    }
    
    #titre1 {
        font-family: 'Roboto';
        font-size: 40px;
        color: mediumseagreen; /* Couleur pour le titre */
        font-weight: bold;
        text-align: center;
        padding-bottom: 10px;
        border-bottom: 3px solid mediumseagreen;
    }

    #presentation, #carte, #contact, #administrateur {
        font-family: 'Roboto';
        font-size: 25px;
        color: black;
        font-weight: 600;
        text-align: center;
    }

  ")),
  
  # Titre de l'application avec l'ID correct
  titlePanel(tags$div("Répartition des membres d'une association en France", id = "titre1")),
  
  # Séparation en onglets
  tabsetPanel(id = "monOnglet",  # Ajout de l'identifiant
              tabPanel("Présentation", 
                       
                       # Section "Bienvenue chez DigiSolidaire"
                       tags$div(
                         tags$span("Bienvenue chez DigiSolidaire 🚀💡", id = "bienvenue"), 
                         tags$br(),  # Saut de ligne
                       ),
                       
                       # Section "Une association dédiée à l’inclusion numérique..."
                       tags$div(
                         tags$i("Une association dédiée à l’inclusion numérique, l’éducation digitale et l’accès aux nouvelles technologies pour tous.", id = "presentation-italic"),
                         tags$br(),  # Saut de ligne
                       ),
                       
                       # Section "Notre association est engagée..."
                       tags$div(
                         "Notre association est engagée. Nous œuvrons pour rendre les nouvelles technologies accessibles à tous en proposant des formations, des ateliers et un accompagnement personnalisé. Rejoignez-nous pour réduire la fracture numérique et construire un avenir digital solidaire !",
                         id = "presentation-normal",
                         style = "margin-bottom: 10px;"
                       ),
                       
                       # Bouton Commencer avant la présentation du projet
                       actionButton("start", "Commencer", 
                                    style="margin-top: 10px; background-color: mediumseagreen; color: white; font-weight: bold; border-radius: 5px; padding: 10px 20px; border: none;"),
                       
                       # Nouveau bloc pour la présentation du projet
                       tags$div(
                         tags$h3("Présentation du projet : OPEN 2025", style = "color: mediumseagreen;"),
                         tags$p(
                           "Notre projet vise à créer une application fonctionnelle pour répertorier l'ensemble des membres d'une association.",
                           style = "font-size: 18px; color: black; font-weight: 500; margin-top: 20px;"
                         )
                       ),
                       
                       # Nouveau bouton "En savoir plus" pour télécharger un PDF
                       downloadButton("pdfDownload", "En savoir plus", 
                                      style="margin-top: 10px; background-color: mediumseagreen; color: white; font-weight: bold; border-radius: 5px; padding: 10px 20px; border: none;")
              ),
              
              tabPanel("Carte", 
                       titlePanel("Carte"),
                       numericInput("latitude", "Latitude :", value = 48.8566, min = -90, max = 90),
                       numericInput("longitude", "Longitude :", value = 2.3522, min = -180, max = 180),
                       selectInput("selected_person", "Sélectionner une personne :", choices = df$Nom, selected = NULL),
                       
                       actionButton("add_marker", "Ajouter un marqueur"),
                       actionButton("reset_map", "Réinitialiser la carte"),
                       tags$div("Carte interactive", id = "carte"),
                       leafletOutput("map", height = "600px")
              ),
              
              
              tabPanel("Administrateur", 
                       tags$div("Espace Administrateur", id = "administrateur"),
                       tags$div("Interface réservée aux administrateurs", 
                                style = "text-align: center; font-size: 20px; font-weight: bold; margin-top: 20px;"),
                       textInput("admin_id", "Identifiant :", ""),
                       passwordInput("admin_pass", "Mot de passe :"),
                       actionButton("admin_login", "Se connecter", 
                                    style="margin-top: 10px; background-color: mediumseagreen; color: white; font-weight: bold; border-radius: 5px; padding: 10px 20px; border: none;")
              ),
              
              tabPanel("Contact", 
                       tags$div("Informations de contact", id = "contact"),
                       fluidRow(
                         column(6, offset = 3,
                                textInput("name", "Nom :", ""),
                                textInput("email", "Email :", ""),
                                textAreaInput("message", "Message :", "", rows = 4),
                                actionButton("send", "Envoyer", 
                                             style="margin-top: 10px; background-color: mediumseagreen; color: white; font-weight: bold; border-radius: 5px; padding: 10px 20px; border: none;")
                         )
                       ),
                       tags$div(
                         "Suivez-nous sur nos réseaux sociaux:", 
                         style = "text-align: center; font-size: 20px; font-weight: bold; margin-top: 20px;"
                       ),
                       tags$div(
                         style = "text-align: center; margin-top: 10px;",
                         tags$a(href = "https://isara.fr/", tags$img(src = "logo_isara.jpg", style = "width: 50px; height:50px;")),
                         tags$a(href = "https://www.instagram.com/isara_lyonavignon/?hl=fr", tags$img(src = "instagram.png", style = "width: 50px; height:50px;")),
                         tags$a(href = "https://fr.linkedin.com/school/isara-lyonavignon/", tags$img(src = "linkedin.png", style = "width: 70px; height:70px;"))
                       )
              )
  )
)
