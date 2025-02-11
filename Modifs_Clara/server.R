server <- function(input, output, session) {
  
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
      addTiles() %>%
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
  
  # Rediriger vers l'onglet "Contact" lorsque le bouton "Commencer" est cliqué
  observeEvent(input$start, {
    updateTabsetPanel(session, "monOnglet", selected = "Contact")
  })
  
  # Téléchargement du fichier PDF
  output$pdfDownload <- downloadHandler(
    filename = function() { 
      paste("Gestion_de_projet.pdf") 
    },
    content = function(file) {
      # Placez votre chemin de fichier PDF ici
      file.copy("Gestion_de_projet.pdf", file)
    }
  )
}