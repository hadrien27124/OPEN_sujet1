library(shiny)
library(leaflet)

server <- function(input, output, session) {
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      setView(lng = 3.59395, lat = 47.3103, zoom = 6) %>%  # Centrage entre Paris et Lyon
      addMarkers(lng = 2.3522, lat = 48.8566, popup = "Paris") %>%
      addMarkers(lng = 4.8357, lat = 45.7640, popup = "Lyon")
  })
}