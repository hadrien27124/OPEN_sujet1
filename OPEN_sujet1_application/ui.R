library(shiny)
library(readxl)
library(leaflet)
library(tidygeocoder)
library(dplyr)

df <- read_excel("Base_de_données.xlsx")

ui <- fluidPage(
# Style de l'entête
  tags$head(
    tags$style(HTML("
    
    /*Import d'une police personnalisée*/
    @font-face {
      font-family: 'Explora';
      src: url('Explora.ttf') format('truetype');
    }
    
    /*Création de l'animation des boutons de la barre d'onglet*/
    @keyframes rebond {
      0% {transform: translateY(0);}
      30% {transform: translateY(-5px);}
      50% {transform: translateY(2px);}
      70% {transform: translateY(-2px);}
      100% {transform: translateY(0);}
    }
    
    /*Style et position de l'entête*/
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
      box-shadow: 2px 2px 10px rgba(0,0,0,0.5);
    }
    
    /*Position du logo*/
    .header img {
      height: 80px;
      width: auto;
      margin-right: 225px;
      margin-left: 20px;
    }
    
    /*Style du titre*/
    .header-title {
      font-family: 'Explora';
      font-size: 48px;
      color: #4b8644;
    }
                    ")
               )
    ),
  

# Style de la barre d'onglet et des onglets
  tags$style(HTML("
  
/*Import de polices personnalisées*/
  @font-face {
      font-family: 'ContrailOne';
      src: url('ContrailOne.ttf') format('truetype');
  }
  
  @font-face {
    font-family: 'Achieve';
    src: url('Achieve.ttf') format('truetype');
  }
   
    
    /*Corps de l'app : couleur de fond*/
    body { 
      background-color: #c7e0a6 ;
      margin-bottom: 30px;
    }
    
    /* Style et position de la barre d'onglets */
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
      box-shadow: 2px 2px 10px rgba(0,0,0,0.5); /* Ombre */
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
    
    /* Contenu des onglets avec bordure et ombre */
    .tab-content {
        background-color: white;
        padding: 20px;
        border-radius: 10px;
        box-shadow: 2px 2px 10px rgba(0,0,0,0.1); /* Ombre */
        margin-top: 10px;
    }
    
    #Presentation, #Carte, #contact, #administrateur {
        font-family: 'ContrailOne';
        font-size: 25px;
        color: black;
        font-weight: 600;
        text-align: center;
    }

  ")),
  
#Implémentation du titre et du logo dans l'entête
  tags$div(class="header",
           tags$img(src="logo.png"),
           tags$div("DigiSolidaire", class="header-title")),

  # Séparation en onglets
tabsetPanel(id = "monOnglet",  # Ajout de l'identifiant
            tabPanel("Présentation", 
                     
                     # Section "Bienvenue chez DigiSolidaire"
                     tags$div(
                       tags$span("Bienvenue chez DigiSolidaire", 
                                 id = "bienvenue", 
                                 style="font-family: ContrailOne; font-size: 25px; color: #4b8644; margin-top: 10px"), 
                       tags$br(),  # Saut de ligne
                       tags$br(),  # Saut de ligne
                     ),
                     
                     # Section "Une association dédiée à l’inclusion numérique..."
                     tags$div(
                       tags$i("Une association dédiée à l’inclusion numérique, l’éducation digitale et l’accès aux nouvelles technologies pour tous.", 
                              id = "presentation-italic", 
                              style="font-family: Achieve; font-weight: bold; font-size: 13px; color: #1f5014; text-align: justify"),
                       tags$br()  # Saut de ligne
                     ),
                     
                     # Section "Notre association est engagée..."
                     tags$div(
                       "Notre association est engagée, nous œuvrons pour rendre les nouvelles technologies accessibles à tous en proposant des formations, des ateliers et un accompagnement personnalisé. Rejoignez-nous pour réduire la fracture numérique et construire un avenir digital solidaire !",
                       id = "presentation-normal",
                       style = "font-family: Achieve; font-weight: bold; font-size: 13px; color: #1f5014; text-align: justify; margin-bottom: 10px;",
                       tags$br()
                     ),
                     
                     # Bouton Contactez nous
                     div(
                       actionButton("start", "Contactez nous", 
                                    style="margin-top: 10px; background-color: #4b8644; font-family: Explora; font-size: 16px; color: white; font-weight: bold; border-radius: 5px; padding: 10px 20px; border: none;"),
                       style="text-align: center; margin-right: 30px"),
                     
                     # Nouveau bloc pour la présentation du projet
                     tags$div(
                       tags$br(),
                       tags$h3("Présentation du projet : OPEN 2025", style = "font-family: ContrailOne; font-size: 25px; color: #4b8644;"),
                       tags$p(
                         "Notre projet vise à créer une application stable et fonctionnelle pour répertorier l'ensemble des membres d'une association. D'autres éléments pourront être ajoutés sur l'interface.",
                         style = "font-family: Achieve; font-size: 15px; color: #1f5014; font-weight: bold; margin-top: 20px;"
                       ),
                       # Section "Présentation des onglets"
                       tags$div(
                         tags$p("Vous pouvez retrouver sur cette application différents onglets :", style= "font-family: Achieve; font-size: 13px; font-weight: bold; color: #1f5014; margin-top: 20px"),
                         tags$ul(
                           tags$li(tags$u("Onglet Présentation"), 
                                   ": Présente l'association, le projet et donne accès à diverses informations supplémentaires avec le bouton En savoir plus. Le bouton nous contacter redirige vers l'ongelt Contact.", 
                                   style= "font-family: Achieve; font-size: 13px; font-weight: bold; color: #1f5014; margin-top: 20px"),
                           tags$li(tags$u("Onglet Carte"), 
                                   ": Représente sur une carte l'ensemble des membres de l'association renseignés dans une base de données. Une sélection via une liste à puce est possible. Une réinitialisation de la sélection est possible via un bouton.",
                                   style="font-family: Achieve; font-size: 13px; font-weight: bold; color: #1f5014; margin-top: 20px"),
                           tags$li(tags$u("Onglet Administrateur"), 
                                   ": Uniquement réservé aux membres adminsitrateurs ayant un identifiant et un mot de passe valides. Cet onglet sert aux adminsitrateurs à renseigner des nouveaux membres dans la base de données et de les afficher sur la carte intéractive.",
                                   style="font-family: Achieve; font-size: 13px; font-weight: bold; color: #1f5014; margin-top: 20px"),
                           tags$li(tags$u("Onglet Contact"), 
                                   ": Permet aux visiteurs de l'application d'envoyer un formulaire pour poser des questions. Les liens vers différents sites et réseaux sociaux sont également disponibles en bas de page. Un bouton crédit présente les membres ayant créer l'interface ainsi que leur répartition des tâches.",
                                   style="font-family: Achieve; font-size: 13px; font-weight: bold; color: #1f5014; margin-top: 20px")
                         ),
                         id = "presentation-normal",
                         style = "margin-bottom: 20px;"
                       )
                       
                     ),
                     
                     # Nouveau bouton "En savoir plus" pour afficher un PDF
                     div(actionButton("showPDF", 
                                      "En savoir plus",
                                      style="margin-top: 10px; background-color: #4b8644; font-family: Explora; font-size: 16px; color: white; font-weight: bold; border-radius: 5px; padding: 10px 20px; border: none;"),
                         style="text-align: center"), 
                     uiOutput("ContenuPDF")
            ),
              
            tabPanel("Carte", 
                     tags$h2("Carte",
                             style="font-family: ContrailOne; font-size: 30px; color: #4b8644; text-align: center; border-top: 2px solid #4b8644; border-bottom: 2px solid #4b8644; padding: 10px; margin-bottom: 25px;"),
                     tags$div(
                       selectInput("selected_person", "Sélectionner une personne :", 
                                   choices = df$Nom, selected = NULL),
                       style = "font-family: ContrailOne; color: #1f5014; font-size: 15px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.5); padding: 10px; border-radius: 5px; width: fit-content; margin-left: 20px; margin-bottom: 20px",
                       
                       actionButton("reset_map", "Réinitialiser la carte")),
                     tags$div("Carte interactive", id = "carte", style="font-family: Explora; font-size: 25px; color: #4b8644 ; margin-top: 35px; margin-bottom: 20px"),
                     leafletOutput("map", height = "600px")
            ),
              
            tabPanel("Administrateur", 
                     tags$div("Espace Administrateur", id = "administrateur", style="font-family: ContrailOne; font-size: 25px; color: #4b8644; margin-bottom: 20px" ),
                     tags$div(uiOutput("private_panel"),style="font-family: Achieve; font-size: 13px; font-weight: bold; color: #1f5014; margin-bottom: 20px"),
                     tags$div(uiOutput("private_mdp"),style = "font-family: ContrailOne; color: #1f5014; font-size: 15px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.5); padding: 10px; border-radius: 5px; width: 90%; margin-left: 20px; margin-bottom: 20px"),
            ),
              

              
            tabPanel("Contact", 
                     tags$div("Informations de contact", id = "contact", style="font-family: ContrailOne; font-size: 25px; color: #4b8644; margin-bottom: 35px"),
                     fluidRow(
                       column(6, offset = 3,
                              tags$div(textInput("name", "Nom : *", ""), style="font-family: Explora; font-size: 15px; color: #1f5014"),
                              tags$div(textInput("email", "Email : *", ""),style="font-family: Explora; font-size: 15px; color: #1f5014"),
                              tags$div(textAreaInput("message", "Message : *", "", rows = 4),style="font-family: Explora; font-size: 15px; color: #1f5014"),
                              tags$div(
                                tags$span("Les champs suivi d'un * sont obligatoires", 
                                          style = "font-family: Achieve; font-weight: bold; color: #1f5014; font-style : italic; font-size: 10px"), 
                              ),
                              actionButton("send", "Envoyer", 
                                           style="margin-top: 10px; background-color: #4b8644; color: white; font-family: Explora; font-size: 17px; font-weight: bold; border-radius: 5px; padding: 10px 20px; border: none;")
                       )
                     ),
                     tags$div(
                       "Suivez-nous sur nos réseaux sociaux:", 
                       style = "text-align: center; font-family: Achieve; color: #1f5014; font-size: 17px; font-weight: bold; margin-top: 50px;"
                     ),
                     tags$div(
                       style = "text-align: center; margin-top: 10px;",
                       tags$a(href = "https://isara.fr/", tags$img(src = "logo_isara.jpg", style = "width: 50px; height:50px;")),
                       tags$a(href = "https://www.instagram.com/isara_lyonavignon/?hl=fr", tags$img(src = "instagram.png", style = "width: 50px; height:50px;")),
                       tags$a(href = "https://fr.linkedin.com/school/isara-lyonavignon/", tags$img(src = "Linkedin.png", style = "width: 50px; height:50px;"))
                     ),
                     
                     #Nouveau bouton crédits
                     actionButton("credits", "Crédits", 
                                  style="color: #1f5014; font-weight: bold; border: none; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.5); padding: 10px; border-radius: 5px; width: fit-content; margin-left: 20px; margin-bottom: 20px")
            )
)
)