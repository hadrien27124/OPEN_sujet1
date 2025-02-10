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
             actionLink("lien_isara_facebook","Facebook"))
    )
  )
)

server <- function(input, output, session) {
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      setView(lng = 2.3522, lat = 48.8566, zoom = 12) # Paris par défaut
  })
}

shinyApp(ui, server)