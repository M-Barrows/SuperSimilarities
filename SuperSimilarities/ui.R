#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)


# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Super Similarities"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      selectInput("characteristics",
                   "Characteristics to Compare:",
                  choices = c('Universe','Alignment','Eye_Color'
                              ,'Sex','GSM','Alive','AppearanceBin','Inaugural_Mo','Inaugural_Yr'
                              ,'IdentitiyStatus'),
                  selected = c('Universe','Alignment','Sex','Alive','AppearanceBin','Inaugural_Yr'
                               ,'IdentitiyStatus'),
                  multiple = T
                  ),
      sliderInput("threshold",
                  "Similarity Threshold",
                  value = 90,
                  min = 0,
                  max = 100,
                  step = 10)
      ),
    
    # Show a plot of the generated distribution
    mainPanel(
       DT::dataTableOutput("dataHead")
    )
  )
))
