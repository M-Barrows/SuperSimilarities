#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(dplyr)
library(readr)
library(tidyverse)
library(DT)
data <- read_csv("./RawData.csv")
com_Matrix <- read_csv("./SimilarityMatrix_2019.csv") %>% 
  select(-1) %>%
  left_join(data %>% select(id,Name), by = c("Hero1"="id")) %>%
  left_join(data %>% select(id,Name), by = c("Hero2"="id")) %>%
  mutate(Hero1 = Name.x, Hero2 = Name.y) %>%
  select(-Name.x,-Name.y)


# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
   
  output$dataHead <- DT::renderDT({
    DT::datatable(com_Matrix %>% 
           select(Hero1,Hero2,input$characteristics) %>%
           mutate(similars = round(((rowSums(.[,3:ncol(.)]))/(ncol(.)-2))*100,digits = 0)) %>%
           filter(similars >= input$threshold)
    , options = list(scrollX = T, sScrollY = '75vh', scrollCollapse = TRUE)
    , extensions = list("Scroller"))
  })
  
})
