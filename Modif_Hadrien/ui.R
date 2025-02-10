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