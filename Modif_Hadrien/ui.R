library(shiny)
library(readxl)
library(leaflet)
library(tidygeocoder)
library(dplyr)


ui <- fluidPage(
  
  # Titre de l'application en utilisant la police précédemment choisie
  titlePanel(tags$div("Répartition des membres d'une association en France", id = "Titre1")),
  
  tabsetPanel(
    
    tabPanel("Présentation", 
             tags$div("Bienvenue dans l'application", id = "presentation")
    ),
    
    tabPanel("Carte", 
             titlePanel("Carte"),
             leafletOutput("map")
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
  )
)))
