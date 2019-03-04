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
