library(shiny)
library(readxl)
library(leaflet)
library(tidygeocoder)
library(dplyr)

df <- read_excel("Base_de_données.xlsx")

ui <- fluidPage(
  tags$head(
    tags$style(HTML("
    
    @font-face {
      font-family: 'Explora';
      src: url('Explora.ttf') format('truetype');
    }
    
    @font-face {
      font-family: 'ContrailOne';
      src: url('ContrailOne.ttf') format('truetype');
    }
    
    @keyframes rebond {
      0% {transform: translateY(0);}
      30% {transform: translateY(-5px);}
      50% {transform: translateY(2px);}
      70% {transform: translateY(-2px);}
      100% {transform: translateY(0);}
    }
    
    .header {
      position: relative;
      background-color: #1f5014 !important;
      height: 100px !important;
      display: flex;
      align-items: center;
      justify-content: flex-start;
      border-radius: 20px;
      margin-top: 20px;
      margin-bottom: 20px;
    }
    
    .header img {
      height: 80px;
      width: auto;
      margin-right: 225px;
      margin-left: 20px;
    }
    
    .header-title {
      font-family: 'Explora';
      font-size: 48px;
      color: #4b8644;
    }
                    ")
               )
    ),
  
  # Modification de la police et du style des onglets
  tags$style(HTML("
  
/*Corps de l'app : couleur de fond*/
  body { 
        background-color: #c7e0a6 ;
        margin-bottom: 30px;
  }
  
/*Barre d'onglet*/
  .nav-tabs > li > a {
    font-family: 'ContrailOne';
    font-size: 18px;
    color: white;
    background-color: #4b8644;
    border-radius: 10px;
    padding: 8px 20px;
    margin-right: 10px;
    margin-bottom: 15px;
    margin-top: 15px;
  }
  
/*Bouton de l'onglet actif*/
  .nav-tabs > li.active > a {
    background-color: #1f5014;
    color: white;
    border-bottom: 3px solid #4b8644;
  }
  
/*Survol de la barre d'onglet*/
  .nav-tabs > li > a:hover {
    animation: rebond 0.6s ease;
    background-color: #1f5014 ;
  }

/*bordures de la barre d'onglet*/
  .nav-tabs {
    border-top: 2px solid #4b8644;
    border-bottom: 2px solid #4b8644;
  }
  
  
  .nav-tabs > li > a {
        border: 1px solid #ccc; /* contour fin */
        box-shadow: 2px 2px 5px rgba(0,0,0,0.1); /* Ajoute une ombre */
    }
    

    
#Contenu des onglet, bordure et ombres
    .tab-content {
        background-color: white;
        padding: 20px;
        border-radius: 10px;
        box-shadow: 2px 2px 10px rgba(0,0,0,0.1); /* Ombre */
        margin-top: 10px;
    }
    
    #presentation, #carte, #contact, #administrateur {
        font-family: 'Roboto';
        font-size: 25px;
        color: black;
        font-weight: 600;
        text-align: center;
    }

  ")),
  
  tags$div(class="header",
           tags$img(src="logo.png"),
           tags$div("DigiSolidaire", class="header-title")),

# Séparation en onglets
  tabsetPanel(id = "monOnglet",  # Ajout de l'identifiant
              tabPanel("Présentation", 
                       
                       # Section "Bienvenue chez DigiSolidaire"
                       tags$div(
                         tags$span("Bienvenue chez DigiSolidaire 🚀💡", id = "bienvenue"), 
                         tags$br(),  # Saut de ligne
                       ),
                       
                       # Section "Une association dédiée à l’inclusion numérique..."
                       tags$div(
                         tags$i("Une association dédiée à l’inclusion numérique, l’éducation digitale et l’accès aux nouvelles technologies pour tous.", id = "presentation-italic"),
                         tags$br(),  # Saut de ligne
                       ),
                       
                       # Section "Notre association est engagée..."
                       tags$div(
                         "Notre association est engagée. Nous œuvrons pour rendre les nouvelles technologies accessibles à tous en proposant des formations, des ateliers et un accompagnement personnalisé. Rejoignez-nous pour réduire la fracture numérique et construire un avenir digital solidaire !",
                         id = "presentation-normal",
                         style = "margin-bottom: 10px;"
                       ),
                       
                       # Bouton Contacter nous avant la présentation du projet
                       actionButton("start", "Contacter nous", 
                                    style="margin-top: 10px; background-color: mediumseagreen; color: white; font-weight: bold; border-radius: 5px; padding: 10px 20px; border: none;"),
                       
                       # Nouveau bloc pour la présentation du projet
                       tags$div(
                         tags$h3("Présentation du projet : OPEN 2025", style = "color: mediumseagreen;"),
                         tags$p(
                           "Notre projet vise à créer une application fonctionnelle pour répertorier l'ensemble des membres d'une association.",
                           style = "font-size: 18px; color: black; font-weight: 500; margin-top: 20px;"
                         ),
                         # Section "Présentation des onglets"
                         tags$div(
                           tags$p("Vous pouvez retrouver sur cette application différents onglets :"),
                           tags$ul(
                             tags$li("Onglet Présentation : Présente l'association, le projet et donne accès à diverses informations supplémentaires avec le bouton En savoir plus"),
                             tags$li("Onglet Carte : Représente sur une carte l'ensemble des membres de l'association renseignés dans une base de données. Une sélection via une liste à puce est possible."),
                             tags$li("Onglet Administrateur : Uniquement réservé aux membres adminsitrateurs ayant un identifiant et un mot de passe. Cet onglet sert aux adminsitrateurs à renseigner des nouveaux membres dans la base de données."),
                             tags$li("Onglet Contact : Permet aux visiteurs de l'application d'envoyer un formulaire pour poser des questions. Les liens vers différents sites et réseaux sociaux sont également disponibles en bas de page")
                           ),
                           id = "presentation-normal",
                           style = "margin-bottom: 10px;"
                         )
                         
                       ),
                       
                       # Nouveau bouton "En savoir plus" pour afficher un PDF
                       actionButton("showPDF", "En savoir plus",
                                    style="margin-top: 10px; background-color: mediumseagreen; color: white; font-weight: bold; border-radius: 5px; padding: 10px 20px; border: none;"), 
                       uiOutput("ContenuPDF")
              ),
              
              tabPanel("Carte", 
                       titlePanel("Carte"),
                       selectInput("selected_person", "Sélectionner une personne :", choices = df$Nom, selected = NULL),
                      
                       actionButton("reset_map", "Réinitialiser la carte"),
                       tags$div("Carte interactive", id = "carte"),
                       leafletOutput("map", height = "600px")
              ),
              
              tabPanel("Administrateur", 
                       tags$div("Espace Administrateur", id = "administrateur"),
                       uiOutput("private_panel"),
                       uiOutput("private_mdp")
              ),
              

              
              tabPanel("Contact", 
                       tags$div("Informations de contact", id = "contact"),
                       fluidRow(
                         column(6, offset = 3,
                                textInput("name", "Nom : *", ""),
                                textInput("email", "Email : *", ""),
                                textAreaInput("message", "Message : *", "", rows = 4),
                                tags$div(
                                  tags$span("Les champs suivi d'un * sont obligatoires", 
                                            style = "font-style : italic; font-size: 12px"), 
                                ),
                                actionButton("send", "Envoyer", 
                                             style="margin-top: 10px; background-color: mediumseagreen; color: white; font-weight: bold; border-radius: 5px; padding: 10px 20px; border: none;")
                         )
                       ),
                       tags$div(
                         "Suivez-nous sur nos réseaux sociaux:", 
                         style = "text-align: center; font-size: 20px; font-weight: bold; margin-top: 20px;"
                       ),
                       tags$div(
                         style = "text-align: center; margin-top: 10px;",
                         tags$a(href = "https://isara.fr/", tags$img(src = "logo_isara.jpg", style = "width: 50px; height:50px;")),
                         tags$a(href = "https://www.instagram.com/isara_lyonavignon/?hl=fr", tags$img(src = "instagram.png", style = "width: 50px; height:50px;")),
                         tags$a(href = "https://fr.linkedin.com/school/isara-lyonavignon/", tags$img(src = "linkedin.png", style = "width: 70px; height:70px;"))
                       ),
                       #Nouveau bouton crédits
                       actionButton("credits", "Crédits", 
                                    style="margin-top: 20px; background-color: #f39c12; color: white; font-weight: bold; border-radius: 15px; padding: 10px 20px; border: none;")
              )
  )
)