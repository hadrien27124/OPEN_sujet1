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
      border-bottom: 3px solid red !important; /* Garder la barre rouge après le clic */
    }

    /* Modifier l'onglet au survol */
    .nav-tabs > li > a:hover {
        background-color: lightgray;
        color: black;
    }

    /* Modifier la barre de fond et l'ombre des onglets */
    .nav-tabs {
        border-bottom: 2px solid #ccc; /* Légère bordure en bas */
    }
    
    .nav-tabs > li > a {
        border: 1px solid #ccc; /* Ajoute un contour fin */
        box-shadow: 2px 2px 5px rgba(0,0,0,0.1); /* Ajoute une ombre légère */
    }
    
    /* Arrière-plan de l'application */
    body {
        background-color: #f5f5f5; /* Gris clair pour un fond doux */
    }
    
    /* Contenu des onglets avec une belle bordure et une ombre */
    .tab-content {
        background-color: white;
        padding: 20px;
        border-radius: 10px;
        box-shadow: 2px 2px 10px rgba(0,0,0,0.1); /* Ombre douce */
        margin-top: 10px;
    }
    
    #titre1 {
        font-family: 'Roboto';
        font-size: 40px;
        color: mediumseagreen; /* Couleur moderne pour le titre */
        font-weight: bold;
        text-align: center;
        padding-bottom: 10px;
        border-bottom: 3px solid mediumseagreen;
    }

    #presentation, #carte, #contact {
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
  tabsetPanel(
    
    tabPanel("Présentation", 
             tags$div("Bienvenue dans l'application", id = "presentation"),
             actionButton("start", "Commencer", 
                          style="margin-top: 10px; background-color: mediumseagreen; color: white; font-weight: bold; border-radius: 5px; padding: 10px 20px; border: none;")
    ),
    
    tabPanel("Carte", 
             tags$div("Carte interactive", id = "carte"),
             leafletOutput("map", height = "600px")
    ),
    
    tabPanel("Contact", 
             tags$div("Informations de contact", id = "contact"),
             
             tags$div(
               actionLink("lien_isara","lien isara"),
               actionLink("lien_isara_insta","Instagram"),
               actionLink("lien_isara_facebook","Facebook")),
             
             tags$div(
               tags$a(
                 href = "https://isara.fr/",
                 tags$img(src = "logo_isara.jpg", style = "width: 50px; height:50px;")
               )
             ))))

server <- function(input, output, session) {
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      setView(lng = 2.3522, lat = 48.8566, zoom = 12) # Paris par défaut
    
    
  })
}

shinyApp(ui, server)