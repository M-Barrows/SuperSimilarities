library(plyr)
library(dplyr)
library(stringr)
library(lubridate)
library(tidyr)

dc <- read.csv("./SuperSimilarities/data/dc-data.csv")
marvel <- read.csv("./SuperSimilarities/data/marvel-data.csv")

marvel <- marvel %>%
  separate(.,FIRST.APPEARANCE,c('firstMonth','y'),sep = "\\-") %>%
  mutate(universe = 'marvel',
         url = paste0("https://marvel.fandom.com", str_remove_all(urlslug,"\\\\")),
         identitiyStatus = ID,
         firstMonth = factor(match(firstMonth,month.abb),labels = month.abb),
         firstYear = Year) %>%
  select(name,universe,ALIGN,EYE,SEX,GSM,ALIVE,APPEARANCES,firstMonth,firstYear,url,identitiyStatus) %>%
  filter(!is.na(firstMonth)) %>%
  na.omit()

dc <- dc %>%
  separate(.,FIRST.APPEARANCE,c('y','firstMonth'),sep = ", ") %>%
  mutate(universe = 'dc',
         url = paste0("https://dc.fandom.com", str_remove_all(urlslug,"\\\\")),
         identitiyStatus = ID,
         firstMonth = factor(match(firstMonth,month.name),labels = month.abb),
         firstYear = YEAR) %>%
  select(name,universe,ALIGN,EYE,SEX,GSM,ALIVE,APPEARANCES,firstMonth,firstYear,url,identitiyStatus) %>%
  filter(!is.na(firstMonth)) %>%
  na.omit()

data <- rbind(marvel, dc)
data <- cbind(1:nrow(data),data)

com <- t(combn(data[,1],2))


#create dummy data
a <- matrix(sample(5, 500, TRUE), ncol = 5)
a<-cbind(a,101:(nrow(a)+100))
com <- t(combn(a[,6],2))
commonalities <- apply(com, 1, function(x){
  a[which(a[,6]==x[1]),1:5] == a[which(a[,6]==x[2],1:5)]
})
com <- as.data.frame(cbind(com,t(commonalities))) %>%
  mutate(sum = rowSums(.[3:7]))
com