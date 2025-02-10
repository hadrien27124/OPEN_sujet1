library(shiny)
library(leaflet)

server <- function(input, output, session) {
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles()
        
  })
}
