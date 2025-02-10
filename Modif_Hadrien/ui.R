library(shiny)
library(readxl)
library(leaflet)
library(tidygeocoder)
library(dplyr)


ui <- fluidPage(
  
  
  tabsetPanel(
    
    tabPanel(
      tags$div("Présentation", id = "presentation"), 
    ),
    
    
    tabPanel(
      tags$div("Carte", id = "map"),
      titlePanel("Carte"),
      leafletOutput("map"),
      
    tabPanel(
      tags$div("Contact", id = "contact")
))))