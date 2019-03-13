library(plyr)
library(dplyr)
library(stringr)
library(lubridate)
library(tidyr)

dc <- read.csv("./SuperSimilarities/data/dc-data.csv")
marvel <- read.csv("./SuperSimilarities/data/marvel-data.csv")

marvel <- marvel %>%
  separate(.,FIRST.APPEARANCE,c('firstMonth','y'),sep = "\\-") %>%
  mutate(universe = as.factor('marvel'),
         url = paste0("https://marvel.fandom.com", str_remove_all(urlslug,"\\\\")),
         identitiyStatus = ID,
         firstMonth = factor(match(firstMonth,month.abb),labels = month.abb),
         firstYear = Year) %>%
  select(name,universe,ALIGN,EYE,SEX,GSM,ALIVE,APPEARANCES,firstMonth,firstYear,url,identitiyStatus) %>%
  filter(!is.na(firstMonth)) %>%
  na.omit()

dc <- dc %>%
  separate(.,FIRST.APPEARANCE,c('y','firstMonth'),sep = ", ") %>%
  mutate(universe = as.factor('dc'),
         url = paste0("https://dc.fandom.com", str_remove_all(urlslug,"\\\\")),
         identitiyStatus = ID,
         firstMonth = factor(match(firstMonth,month.name),labels = month.abb),
         firstYear = YEAR) %>%
  select(name,universe,ALIGN,EYE,SEX,GSM,ALIVE,APPEARANCES,firstMonth,firstYear,url,identitiyStatus) %>%
  filter(!is.na(firstMonth)) %>%
  na.omit()

data <- rbind(marvel, dc) %>%
  filter(APPEARANCES > 50.00) %>%
  mutate(AppearanceBin = .bincode(.$APPEARANCES,seq(from = 50.00,4100.00, by = 100), include.lowest = T)) %>%
  select(name,universe,ALIGN,EYE,SEX,GSM,ALIVE,AppearanceBin,firstMonth,firstYear,identitiyStatus,url,APPEARANCES)
data <- cbind(id = 1:nrow(data),data)


com <- as.data.frame(t(combn(data[,1],2)))
commonalities <- apply(com, 1, function(x){
  data[which(data[,1]==x[1]),3:12] == data[which(data[,1]==x[2]),3:12]
})
com_Matrix <- as.data.frame(cbind(com,t(commonalities))) %>%
  mutate(sum = rowSums(.[3:12]))

#perfect matches
com_Matrix[com_Matrix["sum"]==10,] %>% 
  left_join(data %>% select(id,name), by = c("V1"="id" )) %>% 
  left_join(data %>% select(id,name), by = c("V2" = "id")) %>%
  select(name.x,name.y)

col_Matrix <- read_csv("./SuperSimilarities/SimilarityMatrix.csv")
colnames(col_Matrix) <- c('Hero1','Hero2','Universe','Alignment','Eye_Color'
                          ,'Sex','GSM','Alive','AppearanceBin','Inaugural_Mo','Inaugural_Yr'
                          ,'IdentitiyStatus','TotalSimilarities')
write.csv(col_Matrix,"./SuperSimilarities/SimilarityMatrix_2019.csv")



### Network graph 

edges <- subset(com_Matrix,Hero1==20 | Hero2==20)   #sample(nrow(com_Matrix),500)
edges <- edges %>% 
  dplyr::union(subset(com_Matrix,Hero1 %in% edges$Hero1 & Hero2 %in% edges$Hero2)) %>%
  mutate(
    from = Hero1
    , to = Hero2
    , width = TotalSimilarities/2
    , color = 'gray'
    ) %>%
  filter(TotalSimilarities > 6)
  
nodes <- data %>%
  filter(id %in% c(edges$from, edges$to)) %>%
  select(id,label = Name, color = Universe, value = AppearanceBin) %>%
  mutate(color = ifelse(color == 'marvel','red','blue'),
         value = (value+10)/10)
visNetwork(nodes = nodes,edges = edges) %>%
  visOptions(highlightNearest = list(enabled = T, degree = 2, hover = T)) %>%
  visGroups(groupname = "dc", color = "darkblue") %>%
  visGroups(groupname = "marvel", color = "red")
  #visPhysics(enabled = T) %>%
  #visIgraphLayout()

library(dplyr)
library(visNetwork)
library(readr)
edge <- read_csv("./SuperSimilarities/data/social_network/edges.csv")
node <- read_csv("./SuperSimilarities/data/social_network/nodes.csv")
heros <- node %>% filter(type == 'hero') %>% distinct()
comics <- node %>% filter(type == 'comic') %>% distinct()
network <- read_csv("./SuperSimilarities/data/social_network/hero-network.csv")
network <- network %>% 
  group_by(h1 = pmin(hero1,hero2), h2 = pmax(hero1,hero2)) %>% 
  mutate(length = n()) %>%
  filter(length >= 100) %>%
  mutate(length = (1/length)*1000)
  distinct()
e1 <- network %>% select(from = h1, to = h2, length) %>% filter(from != to) %>% distinct()
# e2 <- e1 %>% 
#   union(
#     network %>% 
#       select(from = h1, to = h2, length) %>%
#       filter(from %in% unique(c(e1$from, e1$to)) & 
#                to %in% unique(c(e1$from, e1$to)) &
#                from != to)
#     ) %>%
#   distinct()
n1 <-  data.frame(id = unique(c(e1$from, e1$to)), label = unique(c(e1$from, e1$to))) %>% distinct()
visNetwork(n1,e1) %>%
  visOptions(highlightNearest = list(enabled = T, degree = 1, hover = T),
             nodesIdSelection = F)
  #visIgraphLayout()
