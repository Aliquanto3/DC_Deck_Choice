library(shiny)

data2 <- read.csv2("Data/Archetype_Data.csv", sep = ";")
ui <- fluidPage(
  titlePanel("Sélection d'archétype Duel Commander"),
  sidebarLayout(
    sidebarPanel(
      sliderInput(
        inputId = "niveau_jeu",
        label = "Niveau de jeu général",
        min = -2,
        max = 2,
        value = 0
      ),
      lapply(unique(data2$Macrotype), function(macrotype) {
        sliderInput(
          inputId = paste0("aisance_avec_", macrotype),
          label = paste0("Aisance avec ", macrotype),
          min = -3,
          max = 1,
          value = 0
        )
      })
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Tableau", dataTableOutput(outputId = "data")),
        tabPanel("Histogramme", plotOutput(outputId = "histogramme"))
      )
    )
  )
)
