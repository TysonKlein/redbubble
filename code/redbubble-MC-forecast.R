library(dplyr)
library(tidyverse)
library(VGAM)

script.dir <- dirname(sys.frame(1)$ofile)
setwd(script.dir)
setwd("..")

load("rda/daily-data.rda")
load("rda/best-model.rda")

simulations <- 100
yrGrowth.factor.unit <- mean(na.omit(daily.data$growth.units))
dollars.per.unit <- mean(top_n(daily.data, 150, daily.data$Date)$mean.sales)/mean(top_n(daily.data, 150, daily.data$Date)$mean.units)
days.ahead <- 1*365 + 15

one.trial <- function(mean.units){
  mean.units*qdagum(runif(1), scale = fit.dagum$estimate["scale"], shape1.a = fit.dagum$estimate["shape1.a"], shape2.p = fit.dagum$estimate["shape2.p"])
}

one.set <- function(){
  set <- daily.data
  head(daily.data)
  for(i in 1:(nrow(set) + days.ahead)) {
    if (i > nrow(set)) {
      sim <- one.trial(set$mean.units[i-365]*yrGrowth.factor.unit)
      row <- data.frame(Date = as.Date("2017-05-01") + i,
                        sales = sim*dollars.per.unit,
                        units = sim,
                        mean.sales = yrGrowth.factor.unit*set$mean.sales[i-365],
                        mean.units = yrGrowth.factor.unit*set$mean.units[i-365],
                        variation.sales = sim*dollars.per.unit/ yrGrowth.factor.unit*set$mean.sales[i-365],
                        growth.sales = NA,
                        growth.units = NA)
      
      set <- rbind(set, row)
    }
    else{
      sim <- one.trial(set$mean.units[i])
      set$sales[i] <- sim*set$mean.sales[i]/set$mean.units[i]
      set$units[i] <- sim
      set$variation.sales[i] <- sim*set$mean.sales[i]/set$mean.units[i]/set$mean.sales[i]
    }
  }
  
  set %>% group_by(month=floor_date(Date, "month")) %>% summarize(total=sum(sales))
}

for (i in 1:simulations) {
  # ... make some data
  single <- one.set()
  data <- single$total
  names(data) <- as.character(single$month)
  
  if(i > 1)
  {
    redbubble.MC.forecast <- rbind(redbubble.MC.forecast, data.frame(t(data))) 
  }
  else
  {
    redbubble.MC.forecast <- data.frame(t(data))
  }
}
redbubble.MC.forecast$i <- NULL
names(redbubble.MC.forecast) <- as.character(single$month)

head(redbubble.MC.forecast)
names(redbubble.MC.forecast) <- format(single$month,"%b%y")

save(redbubble.MC.forecast, file = "rda/redbubble-MC-forecast.rda")