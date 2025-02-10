library(shiny)
library(readxl)
library(leaflet)
library(tidygeocoder)
library(dplyr)
library(writexl)

# Charger le fichier Excel

chemin_fichier <- "Base_de_données.xlsx"
df <- read_excel(chemin_fichier)

# Géocodage avec OpenStreetMap pour ajouter les colonnes lat et long
df <- df %>%
  geocode(address = Adresse, method = "osm")

# Vérifier les noms des colonnes pour s'assurer que lat et long ont été ajoutées
print(colnames(df))

# Sauvegarder le dataframe mis à jour avec lat et long dans le même fichier Excel
write_xlsx(df, "Base_de_données.xlsx")

# Vérifier que les données sont correctement mises à jour
print(df)  # Voir les résultats

# Création du serveur pour la carte Leaflet
server <- function(input, output, session) {
  output$map <- renderLeaflet({
    leaflet(df) %>%
      addTiles() %>%  # Fond de carte
      addMarkers(
        lng = ~long,  # Coordonnée longitude
        lat = ~lat,   # Coordonnée latitude
        popup = ~paste("<b>", Nom, "</b><br/>", Adresse)  # Pop-up avec Nom + Adresse
      )
  })
}
