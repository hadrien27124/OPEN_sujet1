ui <- fluidPage(
  titlePanel("Carte des Associations"),
  leafletOutput("map", height = "600px")
)
