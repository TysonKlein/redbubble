library(VGAM)#for dagum functions
library(tidyverse)
library(lubridate)
library(dplyr)

if (is.null(rstudioapi::getActiveDocumentContext()))
{
  script.dir <- dirname(sys.frame(1)$ofile)
  wd <- script.dir
  setwd(wd)
}else setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

setwd("..")

select <- dplyr::select

#load Data from csv files
artist.sales.report <- read.csv("data/artist-sales-report.csv", header = TRUE)
store.user.report <- read.csv("data/store-users.csv", header = TRUE)
store.user.report$Date <- as.Date(store.user.report$Date)

wrangled.data <- artist.sales.report %>%
  mutate(Date = as.Date(parse_date_time(Order.Date, "ymd")))

wrangled.data$Artists.Cut <- as.numeric(gsub("[^0-9.]", "", wrangled.data$Artists.Cut))
wrangled.data$Retail.Price <- as.numeric(gsub("[^0-9.]", "", wrangled.data$Retail.Price))
wrangled.data$Manufacturers.Cut <- as.numeric(gsub("[^0-9.]", "", wrangled.data$Manufacturers.Cut))
wrangled.data$Qty <- as.numeric(wrangled.data$Qty)

wrangled.data <- wrangled.data %>% select(Date, Order.Number, Product.Type, 
                                          Work, Fulfillment.Country, Destination.Country, 
                                          Destination.State, Qty, Retail.Price, 
                                          Manufacturers.Cut, Artists.Cut) %>% 
                                filter(str_detect(tolower(Work), pattern = ""))

#Create data sets for the price and discount comparisom for stickers
price.stratified <- wrangled.data %>% filter((Date > as.Date("2018-6-15") & Date < as.Date("2018-9-15")) | (Date > as.Date("2018-10-20")), Fulfillment.Country == "United States",Product.Type == "Sticker", Artists.Cut < 4.8)
price.stratified$Artists.Cut <- price.stratified$Artists.Cut/price.stratified$Qty
full.price <- mean(price.stratified$Artists.Cut[price.stratified$Artists.Cut >= 3.8])
full.price
discounts <- data.frame(percent = as.character(seq(0, 50, 5)), cost = seq(full.price, full.price*0.5, -full.price*0.05))
discounts$percent <- paste(discounts$percent,"% discount","")
discounts$percent[1] <- "Full price"

#Save them
save(price.stratified, file = "rda/price-stratified.rda")
save(discounts, file  = "rda/discounts.rda")

order.data <- wrangled.data %>% group_by(Order.Number) %>% summarise(units = sum(Qty))

#Save basic Wrangled data and order data
save(wrangled.data, file = "rda/wrangled-data.rda")
save(order.data, file  = "rda/order-data.rda")

#Create adjusted data with daily mean and standard deviation
alpha = 0.08
daily.data.temp <- wrangled.data %>% 
  group_by(Date) %>%
  summarise(sales = sum(Artists.Cut), units = sum(Qty), users = 0, orders = length(unique(Order.Number)),
            mean.sales = 2, mean.units = 1.5, mean.users = 0, variation.sales = 1.1, growth.sales = NA, growth.units = NA, growth.users = NA)

daily.data <- data.frame(Date = seq(as.Date('2017-4-1'), as.Date(max(wrangled.data$Date)), 1), sales = 0, units = 0, users = 0, orders = 0, mean.sales = 2, mean.units = 1.5, mean.users = 0, mean.orders = 0, variation.sales = 1.1, growth.sales = NA, growth.units = NA, growth.users = NA, growth.orders = NA)
daily.data.temp
match(daily.data$Date[11], daily.data.temp$Date)

offset <- 1

for (i in (offset + 1):nrow(daily.data)) {
  if(!is.na(match(daily.data$Date[i], store.user.report$Date)))
  {
    daily.data$users[i] = store.user.report$Users[match(daily.data$Date[i], store.user.report$Date)]
    if (daily.data$users[i] == 118)
    {
      daily.data$users[i] = daily.data$users[i-1]
    }
  }
  
  if(is.na(match(daily.data$Date[i], daily.data.temp$Date)))
  {
    daily.data$sales[i] = 0;
    daily.data$units[i] = 0;
    daily.data$orders[i] = 0;
  }
  
  else {
  daily.data$sales[i] = daily.data.temp$sales[match(daily.data$Date[i], daily.data.temp$Date)]
  daily.data$units[i] = daily.data.temp$units[match(daily.data$Date[i], daily.data.temp$Date)]
  daily.data$orders[i] = daily.data.temp$orders[match(daily.data$Date[i], daily.data.temp$Date)]
  }
      
  daily.data$mean.sales[i] = alpha*daily.data$sales[i-offset] + (1-alpha)*daily.data$mean.sales[i-1]
  daily.data$mean.units[i] = alpha*daily.data$units[i-offset] + (1-alpha)*daily.data$mean.units[i-1]
  daily.data$mean.users[i] = alpha*daily.data$users[i-offset] + (1-alpha)*daily.data$mean.users[i-1]
  daily.data$mean.orders[i] = alpha*daily.data$orders[i-offset] + (1-alpha)*daily.data$mean.orders[i-1]
  
  if (daily.data$Date[i] > as.Date("2018-5-1"))
  {
    daily.data$growth.sales[i] = daily.data$mean.sales[i]/daily.data$mean.sales[i-365]
    daily.data$growth.units[i] = daily.data$mean.units[i]/daily.data$mean.units[i-365]
    daily.data$growth.users[i] = daily.data$mean.users[i]/daily.data$mean.users[i-365]
    daily.data$growth.orders[i] = daily.data$mean.orders[i]/daily.data$mean.orders[i-365]
  }
  
  daily.data$variation.sales[i] = daily.data$sales[i]/daily.data$mean.sales[i-1]
}

#only keep data from after may 1st 2017
daily.data <- daily.data  %>%
filter(Date >= '2017-5-1')

#Week factor lookup function
total.mean <- mean(daily.data$sales)
week.Lookup.data <- daily.data %>% group_by(weekday = weekdays(Date)) %>% summarise(fac = mean(sales)/total.mean)
month.lookup.data <- daily.data %>% group_by(monthday = day(Date)) %>% summarise(fac = mean(sales)/total.mean)
week.Lookup <- function(date) {
  day <- weekdays(as.Date(date))
  return(week.Lookup.data$fac[which(week.Lookup.data$weekday == day)])
}
month.Lookup <- function(date) {
  day <- day(as.Date(date))
  return(month.lookup.data$fac[which(month.lookup.data$monthday == day)])
}

#Function for converting linear model coefficients to an actual model
create.model <- function(LM, data)
{
  model <- LM$coefficients[1]*data$trend.Linear*0
  coef <- data.frame(val = LM$coefficients)
  for (N in 1:nrow(coef)) {
    if(rownames(coef)[N] == "(Intercept)")
    {
      model <- model + coef["(Intercept)",1]
    } else{
      model <- model + coef[N,1]*data[,rownames(coef)[N]]
    }
  }
  return(model)
}

#Daily trend data wrangling from google trends
google.trends.report <- read.csv("data/google-trends-data.csv", header = TRUE)
google.trends.report$Week <- as.Date(google.trends.report$Week)

orders.per.user <- daily.data$mean.orders/daily.data$mean.users
daily.trend <- data.frame()
daily.trend <- google.trends.report[rep(seq_len(nrow(google.trends.report)), 7), ]
daily.trend <- with(daily.trend, daily.trend[order(Week), ])
daily.trend$Week <- rep(google.trends.report$Week, each=7) + 0:6
rownames(daily.trend) <- 1:nrow(daily.trend)
daily.trend$Week <- as.Date(daily.trend$Week, as.Date("1970-01-01"))
colnames(daily.trend)[1] <- "Date"

#Trends Data
years.back <- 1
trend.data <- data.frame(Date = min(as.numeric(daily.data$Date)):max(as.numeric(daily.data$Date)+365*years.back))
trend.data$Date <- as.Date(trend.data$Date, as.Date("1970-01-01"))

trend.data

for (i in 1:nrow(trend.data)) {
  trend.data$trend.Redbubble[i] =  daily.trend$Redbubble[match(trend.data$Date[i]-years.back*365, daily.trend$Date)]
  trend.data$trend.NatPark[i] = daily.trend$National.Park[match(trend.data$Date[i]-years.back*365 - 9, daily.trend$Date)]
  trend.data$trend.RoadTrip[i] = daily.trend$Road.Trip[match(trend.data$Date[i]-years.back*365, daily.trend$Date)]
  trend.data$trend.Sticker[i] =  daily.trend$Sticker[match(trend.data$Date[i]-years.back*365, daily.trend$Date)]
  trend.data$trend.Shopping[i] = daily.trend$Shopping[match(trend.data$Date[i]-years.back*365, daily.trend$Date)]
  trend.data$trend.Weekend[i] = daily.trend$Weekend[match(trend.data$Date[i]-years.back*365 - 3, daily.trend$Date)]
  trend.data$trend.Linear[i] = (max(c(as.numeric(trend.data$Date[i]) - as.numeric(as.Date("2017-05-01")),1)))
  trend.data$trend.dayofweek[i] <- week.Lookup(trend.data$Date[i])
  trend.data$trend.dayofmonth[i] <- month.Lookup(trend.data$Date[i])
  if (i > 365)
  {
  trend.data$previous.year.users[i] <- daily.data$users[i-365]
  trend.data$previous.year.sales[i] <- daily.data$sales[i-365]
  } else
  {
    trend.data$previous.year.users[i] <- daily.data$users[i]*trend.data$trend.Linear[i]
    trend.data$previous.year.sales[i] <- daily.data$sales[i]*trend.data$trend.Linear[i]
  }
  if(trend.data$Date[i] <= as.Date(max(as.numeric(daily.data$Date)), as.Date("1970-01-01")))
  {
    trend.data$orders.per.user[i]<- daily.data$mean.orders[i]/daily.data$mean.users[i]
    trend.data$dollars.per.order[i]<- daily.data$mean.sales[i]/daily.data$mean.orders[i]
  } else
  {
    trend.data$orders.per.user[i]<- trend.data$orders.per.user[i-365]
    trend.data$dollars.per.order[i]<- trend.data$dollars.per.order[i-1]
  }
}

compare.data <-daily.data$mean.sales
linear.model <- lm(compare.data ~ trend.Redbubble + trend.NatPark + trend.RoadTrip + trend.Sticker
                   + trend.Shopping + trend.Weekend + trend.Linear
                   + trend.dayofweek + trend.dayofmonth,
                   data = trend.data[1:nrow(daily.data),])
lm <- linear.model %>% summary()
lm$coefficients

plot(daily.data$Date, daily.data$mean.sales)
sum(daily.data$sales)

model <- create.model(linear.model, trend.data)
model <- data.frame(Date = as.Date(min(as.numeric(daily.data$Date)):max(as.numeric(daily.data$Date)+365*years.back),as.Date("1970-01-01")),
                    forecast = model,
                    actual = 0,
                    error = 0)
model<- na.omit(model)
for (i in 1:nrow(model)) {
  model$actual[i] = model$actual[i] + daily.data$mean.sales[i]
  model$error[i] = model$actual[i] - model$forecast[i]
}
model<- na.omit(model)

#Save daily
save(daily.data, file = "rda/daily-data.rda")
write.csv(daily.data, file = "data/daily-data.csv")

#Save model
save(model, file = "rda/model.rda")
write.csv(model, file = "data/model.csv")
lm <- linear.model %>% summary()
linear.model.disp <- data.frame(lm$coefficients)
colnames(linear.model.disp) <- c("Estimate", "Standard Error", "t value", "p value")
save(linear.model.disp, file = "rda/linear-model-disp.rda")
save(linear.model, file = "rda/linear-model.rda")
