library(shiny)
library(dplyr)
library(readr)
library(sf)
library(tmap)
library(leaflet)
library(htmltools)
library(shinyjs)
library(cochr)

ui <- fluidPage(
  useShinyjs(),

  titlePanel("Carte de mes coches eBird"),

  sidebarLayout(
    tagAppendAttributes(
      sidebarPanel(
        tags$details(
          open = TRUE,
          tags$summary("Comment télécharger vos données eBird"),
          tags$ol(
            tags$li(tags$a("Allez sur eBird", href = "https://ebird.org/myebird", target = "_blank")),
            tags$li("Cliquez sur ", tags$b("Mon eBird")),
            tags$li("Cliquez sur ", tags$b("Télécharger mes données")),
            tags$li("Cliquez sur ", tags$b("Request My Observations")),
            tags$li("Allez chercher le fichier dans vos mails")
          )
        ),

        br(),

        fileInput(
          "ebird_file",
          "Uploader MyEBirdData.csv",
          accept = ".csv"
        )
      ),
      id = "sidebar"
    ),

    mainPanel(
      leafletOutput("carte", height = "800px")
    )
  )
)


server <- function(input, output, session) {

  output$carte <- leaflet::renderLeaflet({
    shiny::req(input$ebird_file)

    cochr::bird_map(input$ebird_file$datapath)
  })
}

shinyApp(ui, server)
