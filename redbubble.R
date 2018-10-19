library(readr)
library(ggplot2)
library(magrittr)
library(lubridate)
library(ggrepel)
library(dplyr)
require(reshape2)

redbubble <- read_csv("R/redbubble.csv", col_names = FALSE)
redbubble <- redbubble %>% 
  mutate(mean = X1, sd = X2, day = as.numeric(rownames(redbubble))) %>% 
  select(mean, sd, day)

head(redbubble)

simulations <- 1000
sd.factor <- 0.55
yrGrowth.factor <- 2.12
days.ahead <- 1*365 + 15

one.trial <- function(mean, sd){
  
  Factor <- 1
  Shape <- mean*mean/(sd*sd)
  Scale <- sd*sd/mean
  
  qgamma(runif(1), Shape, scale = Scale)
}

one.set <- function(){
  set <- redbubble %>% mutate(simulated = 0, date = as.Date("2017-05-01") + day)
  for(i in 1:(nrow(set) + days.ahead)) {
    if (i > nrow(set)) {
    row <- data.frame(mean = yrGrowth.factor*set$mean[i-365],
                      sd = yrGrowth.factor*set$mean[i-365]*sd.factor,
                      day = i,
                      simulated = one.trial(set$mean[i-365]*yrGrowth.factor, set$mean[i-365]*yrGrowth.factor*sd.factor),
                      date = as.Date("2017-05-01") + i)
    
    set <- rbind(set, row)
    }
    else{
    set$simulated[i] <- one.trial(set$mean[i], set$sd[i])
    }
  }
  
  set %>% group_by(month=floor_date(date, "month")) %>% summarize(total=sum(simulated))
}

datalist = list()

for (i in 1:simulations) {
  # ... make some data
  single <- one.set()
  data <- single$total
  names(data) <- as.character(single$month)
  data$i <- i  # maybe you want to keep track of which iteration produced it?
  datalist[[i]] <- data # add it to your list
}

results <- dplyr::bind_rows(datalist)
names(results) <- format(single$month,"%b%y")

realMonths <- c(166.48, 274.25, 320.98, 453.91, 344.39, 340.81,
                465.41, 536.69, 326.99, 280.21, 303.37, 298.61,
                357.58, 512.02, 778.18, 843.55, 787.08, 325.93)
numRealMonths <- round(length(realMonths))
realMonths <- as.data.frame(t(realMonths))
names(realMonths) <-format(single$month[seq(1, numRealMonths, 1)],"%b%y")

col_names <- colnames(realMonths)
bigger <- data.frame(1)
for (i in 1:ncol(realMonths)) {
bigger[i] <-  sum(results[,col_names[i]]<realMonths[,col_names[i]])/simulations
}
names(bigger) <-names(realMonths)
melted <- melt(bigger)

results[,ncol(results)] <- NULL

ggplot() + 
  geom_boxplot(data = melt(results), aes(x=variable, y = value), fill="slateblue", alpha=0.2) +
  geom_point(data = melt(realMonths), colour = 'red', size = 2, aes(x=variable, y = value)) +
  geom_text(data = melted, aes(x=variable, y=10),label = round(100*melted$value))
  scale_y_continuous(breaks = round(seq(0, max(results), by = 100),2))