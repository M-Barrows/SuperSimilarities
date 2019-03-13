##-------------------------------------------##
##          Super Similarities               ##
##                                           ##
##  An interactive look at superheros,       ##
##  their characteristics, and relationships ##
##  to each other.                           ##
##-------------------------------------------##

library(shiny)
library(DT)
library(shinythemes)
library(visNetwork)

# Define UI for application that draws a histogram
shinyUI(
  navbarPage( "Super Similarities",theme = shinytheme("superhero"),
                    
  tabPanel("Network",
           fluidRow(
             column(2,
                    fluidRow(
                      shiny::HTML("<p>Have you ever wondered how your favorite super 
                                  hero characters relate to one another? Is Captain America 
                                  the center of the Marvel Universe? What do The Hulk and 
                                  Catwoman have in common?</p>
                                  <p>This application started as 
                                  a way for me to gain experience creating network
                                  diagrams and comparrison matricies. And, while this may
                                  not be the most robust analysis, I hope it provides a fun, new
                                  way to explore details about your favorite characters. </p>
                                  <br>
                                  <p>Start your exploration below by adjusting the Shared 
                                  comic threshold of the graph to the right. Only characters
                                  who have appeared in at least that many comics together will
                                  be connected. Higher values will restrict the graph to stronger
                                  relationships and visa versa.</p>")
                    ),
                    fluidRow(
                      numericInput("netThreshold",
                                   "Shared Appearances",
                                   value = 150,
                                   min = 80,
                                   max = 2000,
                                   step = 100)
                    ),
                    fluidRow(
                      shiny::HTML("<p>All code for this app can be found <a href= ' '>here</a> 
                                  and the data can be found 
                                  <a href= 'https://www.kaggle.com/csanhueza/the-marvel-universe-social-network'>here</a> 
                                  and <a href= 'https://www.kaggle.com/fivethirtyeight/fivethirtyeight-comic-characters-dataset#marvel-wikia-data.csv '>here</a></p>")
                    )
             ),
             column(10,
                    visNetworkOutput("networkGraph",height = '90vh',width = '80vw'))
           )
      
  ),
  tabPanel("Details",
           
           fluidRow(
             column(2,
                    shiny::HTML("<p>Here you can select characteristics you would like to 
                                compare across almost 1 million pairs of superheros from
                                both the Marvel and DC universe. You can also set the minimum 
                                level of similarity between the returned character pairs. 
                                Of all 850,000 character pairs, only 27 are perfect pairs.</p>")),
             column(9,
                    fluidRow(
                      column(4,
                             selectInput("characteristics",
                                         "Characteristics to Compare:",
                                         choices = c('Universe','Alignment','Eye_Color'
                                                     ,'Sex','GSM','Alive','AppearanceBin','Inaugural_Mo','Inaugural_Yr'
                                                     ,'IdentitiyStatus'),
                                         selected = c('Universe','Alignment','Sex','Alive','AppearanceBin','Inaugural_Yr'
                                                      ,'IdentitiyStatus'),
                                         multiple = T
                             )
                       ),
                      column(8,
                             sliderInput("threshold",
                                         "Similarity Threshold",
                                         value = 90,
                                         min = 0,
                                         max = 100,
                                         step = 10)
                       )
                      
                    ),
                    fluidRow(
                      DT::dataTableOutput("dataHead")
                    )
              )
             
             
           )
    )
  )
)
