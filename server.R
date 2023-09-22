library(shiny)
library(dplyr)
library(ggplot2)

server <- function(input, output) {
  
  data <- read.csv2("Data/Archetype_Data.csv", sep = ";")
  data$RevisedWinrate <- rep(NA,nrow(data))
  ratioSkill = c("Low" = 1/2, "Mid" = 1, "High" = 2)
  
  revisedData <- reactive({
    
    # Calcul du winrate ajusté par le niveau de jeu général
    
    for (i in 1:nrow(data)){
      skillI <- data[i,"Skill"]
      inputI <- input[["niveau_jeu"]]
      ratioSkillI = case_when(
        skillI == "Low" ~ 1 + ratioSkill["Low"] * inputI / 10,
        skillI == "Mid" ~ 1 + ratioSkill["Mid"] * inputI / 10,
        skillI == "High" ~ 1 + ratioSkill["High"] * inputI / 10,
        TRUE ~ (1 + inputI/10)
      )
      data[i,"RevisedWinrate"] = data[i,"Winrate"] * ratioSkillI
    }
      
    # Calcul du winrate ajusté par l'aisance avec chaque macrotype
    for (i in 1:nrow(data)){
      macrotypeI <- data[i,"Macrotype"]
      inputI <- input[[paste0("aisance_avec_", macrotypeI)]]
      data[i,"RevisedWinrate"] = data[i,"RevisedWinrate"] * (1+inputI/10)
    }
    
    # Limite le nombre de chiffres apparaissant à l'écran
    data$RevisedWinrate = round(data$RevisedWinrate,digits = 2)
    
    # Tri des données selon la colonne RevisedWinrate
    
    data <- data[order(data$RevisedWinrate, decreasing = TRUE),]
    
    # Sélectionne les colonnes à afficher
    
    data <- data[,c("Macrotype", "Nom", "Skill", "Winrate", "RevisedWinrate")]
    
    data
  })
  
  output$data <- renderDataTable({
    return(revisedData())
  })
  
  output$histogramme <- renderPlot({
    data = revisedData()
    
    ggplot(data, aes(x = RevisedWinrate, y = reorder(Nom,RevisedWinrate), fill = Macrotype)) +
      geom_bar(stat="identity") +
      theme_minimal() +
      labs(x = "Revised Winrate", y = "Commandant") + 
      theme(axis.text=element_text(size=12),legend.text=element_text(size=12),
            axis.title=element_text(size=14,face="bold")) +
      geom_text(aes(label = round(data$RevisedWinrate,digits = 2)), hjust = 1.5, colour = "white")
  })
}
