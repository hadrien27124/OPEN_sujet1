library(shiny)
library(readxl)
library(leaflet)
library(tidygeocoder)
library(dplyr)
library(writexl)


# Charger le fichier Excel
df <- read_excel("Base_de_données.xlsx")

# Vérifier si les colonnes lat et long existent déjà
if (!("lat" %in% colnames(df) && "long" %in% colnames(df))) {
  # Géocodage uniquement si les colonnes n'existent pas
  df <- df %>%
    geocode(address = Adresse, method = "osm")
  
  # Sauvegarder le dataframe mis à jour avec lat et long dans le fichier Excel
  write_xlsx(df, "Base_de_données.xlsx")
}

# Vérifier les noms des colonnes pour s'assurer que lat et long ont été ajoutées
# print(colnames(df))


server <- function(input, output, session) {
  # Liste des identifiants et mots de passe autorisés
  credentials <- data.frame(
    id = c("admin1", "admin2"),
    pass = c("password1", "password2"),
    stringsAsFactors = FALSE
  )
  
  # Observer l'événement de clic sur le bouton de connexion
  observeEvent(input$admin_login, {
    req(input$admin_id, input$admin_pass)  # S'assurer que les champs ne sont pas vides
    
    # Vérifier si les informations d'identification sont correctes
    user <- credentials[credentials$id == input$admin_id & credentials$pass == input$admin_pass, ]
    
    if (nrow(user) == 1) {
      output$login_message <- renderText("Connexion réussie. Bienvenue!")
      # Ici, vous pouvez ajouter le code pour afficher le contenu réservé aux administrateurs
    } else {
      output$login_message <- renderText("Identifiant ou mot de passe incorrect.")
    }
  })
  # Création d'un objet réactif pour stocker les marqueurs
  markers <- reactiveVal(data.frame(lng = numeric(), lat = numeric()))
  
  # Ajouter un marqueur
  observeEvent(input$add_marker, {
    new_marker <- data.frame(lng = input$longitude, lat = input$latitude)
    markers(rbind(markers(), new_marker))  # Ajout du nouveau marqueur
  })
  
  # Réinitialiser la carte (supprimer tous les marqueurs)
  observeEvent(input$reset_map, {
    markers(data.frame(lng = numeric(), lat = numeric()))  # Réinitialisation des marqueurs
  })
  
  #Affichage de la carte
  output$map <- renderLeaflet({
    leaflet(df) %>%
      addTiles() %>%  # Fond de carte
      addMarkers(
        lng = ~long,  # Coordonnée longitude
        lat = ~lat,   # Coordonnée latitude
        popup = ~paste0(
          "<b>📌 Nom :</b> ", df$Nom, "<br>",
          "<b>🙍 Prénom :</b> ", df$Prénom, "<br>",
          "<b>📍 Adresse :</b> ", df$Adresse ))
  })
  
  # Mise à jour des marqueurs
  observe({
    leafletProxy("map") %>%
      clearMarkers() %>%
      addMarkers(data = markers(), ~lng, ~lat, popup = "Nouveau point")
  })
}

