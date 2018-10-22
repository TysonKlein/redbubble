library(dplyr)
library(tidyverse)

script.dir <- dirname(sys.frame(1)$ofile)
setwd(script.dir)
setwd("..")

load("rda/mean-and-sd.rda")

simulations <- 10
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
  set <- mean.and.sd %>% mutate(simulated = 0, date = as.Date("2017-05-01") + day)
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

redbubble.MC.forecast <- dplyr::bind_rows(datalist)
names(redbubble.MC.forecast) <- format(single$month,"%b%y")

save(redbubble.MC.forecast, file = "rda/redbubble-MC-forecast.rda")