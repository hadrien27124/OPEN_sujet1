library(shiny)
library(readxl)
library(leaflet)
library(dplyr)

# Charger la base de données
df <- read_excel("Base_de_données.xlsx")

# Renommer les colonnes GPS correctement
df <- df %>%
  rename(lat = `lat...4`, long = `long...5`)

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
