library(shiny)
library(readxl)
library(leaflet)
library(tidygeocoder)
library(dplyr)
library(writexl)

# Charger le fichier Excel

df <- read_excel("Base_de_données.xlsx")

# Vérifier si la colonne 'Adresse' existe
if (!"Adresse" %in% colnames(df)) {
  stop("La colonne 'Adresse' n'existe pas dans le fichier Excel.")
}

# Si les colonnes 'lat' et 'long' n'existent pas, les créer
if (!"lat" %in% colnames(df)) {
  df$lat <- NA
}
if (!"long" %in% colnames(df)) {
  df$long <- NA
}

# Vérifier les lignes où 'lat' et 'long' sont NA (c'est-à-dire où ces colonnes sont vides)
df <- df %>%
  mutate(
    lat = ifelse(is.na(lat) & is.na(long), geocode(address = Adresse, method = "osm")$lat, lat),
    long = ifelse(is.na(lat) & is.na(long), geocode(address = Adresse, method = "osm")$long, long)
  )

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

