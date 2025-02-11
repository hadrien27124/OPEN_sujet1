library(shiny)
library(readxl)
library(leaflet)
library(tidygeocoder)
library(dplyr)

ui <- fluidPage(
  
  # Modification de la police et du style des onglets
  tags$style(HTML("/* Styles personnalisés */")),
  
  # Titre de l'application avec l'ID correct
  titlePanel(tags$div("Répartition des membres d'une association en France", id = "titre1")),
  
  # Séparation en onglets
  tabsetPanel(
    
    tabPanel("Présentation", 
             tags$div("Bienvenue dans l'application", id = "presentation"),
             actionButton("start", "Commencer", 
                          style="margin-top: 10px; background-color: mediumseagreen; color: white; font-weight: bold; border-radius: 5px; padding: 10px 20px; border: none;")
    ),
    
    tabPanel("Carte", 
             titlePanel("Carte Interactive avec Géocodage"),
             
             sidebarLayout(
               sidebarPanel(
                 selectInput("nom_selectionne", "Sélectionnez une personne :", choices = NULL),
                 actionButton("reset_map", "Réinitialiser la carte")
               ),
               
               mainPanel(
                 leafletOutput("map", width = "100%", height = "600px")
               )
             ),
             
             numericInput("latitude", "Latitude :", value = 48.8566, min = -90, max = 90),
             numericInput("longitude", "Longitude :", value = 2.3522, min = -180, max = 180),
             
             actionButton("add_marker", "Ajouter un marqueur"),
             actionButton("reset_map", "Réinitialiser la carte"),
             tags$div("Carte interactive", id = "carte")
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
             
             tags$div("Suivez-nous sur nos réseaux sociaux:", style = "text-align: center; font-size: 20px; font-weight: bold; margin-top: 20px;"),
             
             tags$div(style = "text-align: center; margin-top: 10px;",
                      tags$a(href = "https://isara.fr/", tags$img(src = "logo_isara.jpg", style = "width: 50px; height:50px;")),
                      tags$a(href = "https://www.instagram.com/isara_lyonavignon/?hl=fr", tags$img(src = "instagram.png", style = "width: 50px; height:50px;")),
                      tags$a(href = "https://fr.linkedin.com/school/isara-lyonavignon/", tags$img(src = "linkedin.png", style = "width: 70px; height:70px;"))
             )
    )
  )
)
