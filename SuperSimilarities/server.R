##-------------------------------------------##
##          Super Similarities               ##
##                                           ##
##  An interactive look at superheros,       ##
##  their characteristics, and relationships ##
##  to each other.                           ##
##-------------------------------------------##

library(shiny) #Application creation
library(dplyr) #Data Manipulation
library(readr) #Data Import
library(tidyverse) #Data Manipulation
library(DT) #Table Printing
library(igraph) #Network Maps
library(visNetwork) #Network Maps

data <- read_csv("./RawData.csv")
com_Matrix <- read_csv("./SimilarityMatrix_2019.csv") %>% 
  select(-1) %>%
  left_join(data %>% select(id,Name), by = c("Hero1"="id")) %>%
  left_join(data %>% select(id,Name), by = c("Hero2"="id")) %>%
  mutate(Hero1 = Name.x, Hero2 = Name.y) %>%
  select(-Name.x,-Name.y)

edges <- read_csv("./data/social_network/edges.csv")
nodes <- read_csv("./data/social_network/nodes.csv")
network <- read_csv("./data/social_network/hero-network.csv")
# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
   
  output$dataHead <- DT::renderDT({
    DT::datatable(com_Matrix %>% 
           select(Hero1,Hero2,input$characteristics) %>%
           mutate(similars = round(((rowSums(.[,3:ncol(.)]))/(ncol(.)-2))*100,digits = 0)) %>%
           filter(similars >= input$threshold)
    , options = list(scrollX = T, sScrollY = '75vh', scrollCollapse = TRUE)
    , extensions = list("Scroller")
    , style = 'bootstrap')
  })

  output$networkGraph <- renderVisNetwork({
    heros <- nodes %>% filter(type == 'hero') %>% distinct()
    #comics <- nodes %>% filter(type == 'comic') %>% distinct()
    network <- network %>% 
      mutate(hero1 = sapply(strsplit(hero1,"/"), `[`, 1),
             hero2 = sapply(strsplit(hero2,"/"), `[`, 1)) %>%
      group_by(h1 = pmin(hero1,hero2), h2 = pmax(hero1,hero2)) %>% 
      mutate(length = n()) %>%
      filter(length >= input$netThreshold) %>%
      mutate(length = (1/length)*1000) %>%
      distinct()
    e1 <- network %>% select(from = h1, to = h2, length) %>% filter(from != to) %>% distinct()
    n1 <-  data.frame(id = unique(c(e1$from, e1$to))
                      , label = unique(c(e1$from, e1$to))
                      , font.color = 'white', color = '#DF691A') %>% distinct()
    visNetwork(n1,e1) %>%
      visOptions(highlightNearest = list(enabled = T, degree = 1, hover = T),
                 nodesIdSelection = F)
  })
  
  
})
