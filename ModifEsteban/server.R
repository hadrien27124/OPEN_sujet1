library(shiny)
library(readxl)
library(leaflet)
library(dplyr)

# Charger la base de données
df <- read_excel("Base_de_données.xlsx")

# Vérifier les noms des colonnes
print(names(df))  # Pour vérifier si les colonnes sont bien "lat" et "long"

# Serveur Shiny
server <- function(input, output, session) {
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
}


 

