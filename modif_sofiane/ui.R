library(shiny)
library(leaflet)

ui <- fluidPage(
  
  # Titre de l'application
  titlePanel(tags$div("Répartition des membres d'une association en France", id = "Titre1")),
  
  tabsetPanel(
    
    tabPanel("Présentation", 
             tags$div("Bienvenue dans l'application", id = "presentation")
    ),
    
    tabPanel("Carte", 
             titlePanel("Carte"),
             
             # Champs pour entrer les coordonnées
             numericInput("latitude", "Latitude :", value = 48.8566, min = -90, max = 90),
             numericInput("longitude", "Longitude :", value = 2.3522, min = -180, max = 180),
             
             # Boutons pour ajouter et réinitialiser les marqueurs
             actionButton("add_marker", "Ajouter un marqueur"),
             actionButton("reset_map", "Réinitialiser la carte"),
             
             leafletOutput("map")
    ),
    
    tabPanel("Contact", 
             tags$div("Informations de contact", id = "contact")
    )
  )
)
