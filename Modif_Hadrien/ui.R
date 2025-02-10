library(shiny)
library(readxl)
library(leaflet)
library(tidygeocoder)
library(dplyr)


ui <- fluidPage(
  
  tabsetPanel(
    
    tabPanel("Présentation", 
             tags$div("Bienvenue dans l'application", id = "presentation")
    ),
    
    tabPanel("Carte", 
             titlePanel("Carte"),
             leafletOutput("map")
    ),
    
<<<<<<< HEAD
    tabPanel(
      tags$div("Carte", id = "map"),
      titlePanel("Carte"),
      leafletOutput("map"),
      
    tabPanel(
      tags$div("Contact", id = "contact")
))))
=======
    tabPanel("Contact", 
             tags$div("Informations de contact", id = "contact")
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
>>>>>>> f35f328e5ea9490dc5a0687c0cf1ecfe049c4657
