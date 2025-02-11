library(shiny)
library(readxl)
library(leaflet)
library(tidygeocoder)
library(dplyr)
library(writexl)

# Charger le fichier Excel
df <- read_excel("Base_de_données.xlsx")

# Filtrer uniquement les adresses où lat et long sont vides (NA)
adresses_a_geocoder <- df %>%
  filter(is.na(lat) & is.na(long) & !is.na(Adresse)) %>%
  select(Adresse)

# Vérifier qu'il y a des adresses à géocoder
if (nrow(adresses_a_geocoder) > 0) {
  
  # Géocoder avec OpenStreetMap (OSM)
  coordonnees <- geocode(adresses_a_geocoder, adresses_a_geocoder$Adresse,method = "osm")
  
  # Ajouter les résultats au dataframe temporaire
  adresses_a_geocoder$lat <- coordonnees$lat
  adresses_a_geocoder$long <- coordonnees$long
  
  # Mettre à jour uniquement les lignes où lat et long étaient NA
  df <- df %>%
    left_join(adresses_a_geocoder %>% select(Adresse, lat, long), by = "Adresse") %>%
    mutate(
      lat = coalesce(lat.x, lat.y),
      long = coalesce(long.x, long.y)
    ) %>%
    select(-lat.x, -lat.y, -long.x, -long.y)  # Supprimer les colonnes temporaires créées par `left_join`
}

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
