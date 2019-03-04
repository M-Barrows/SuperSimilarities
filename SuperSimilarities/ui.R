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
                  choices = c('universe','ALIGN','EYE','SEX','GSM','ALIVE'
                              ,'AppearanceBin','firstMonth','firstYear'
                              ,'identitiyStatus'),
                  selected = c('universe','ALIGN','SEX','ALIVE','AppearanceBin'
                               ,'firstYear','identityStatus'),
                  multiple = T
                  )
      ),
    
    # Show a plot of the generated distribution
    mainPanel(
       tableOutput("dataHead")
    )
  )
))
