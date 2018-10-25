library(tidyverse)
library(lubridate)

#script.dir <- dirname(sys.frame(1)$ofile)
wd <- script.dir
setwd(wd)
setwd("..")

select <- dplyr::select

#load Data from csv file
artist.sales.report <- read.csv("data/artist-sales-report.csv", header = TRUE)

wrangled.data <- artist.sales.report %>%
  mutate(Date = as.Date(Order.Date))

wrangled.data$Artists.Cut <- as.numeric(gsub("[^0-9.]", "", wrangled.data$Artists.Cut))
wrangled.data$Retail.Price <- as.numeric(gsub("[^0-9.]", "", wrangled.data$Retail.Price))
wrangled.data$Manufacturers.Cut <- as.numeric(gsub("[^0-9.]", "", wrangled.data$Manufacturers.Cut))
wrangled.data$Qty <- as.numeric(wrangled.data$Qty)

head(wrangled.data)

wrangled.data <- wrangled.data %>% select(Date, Order.Number, Product.Type, 
                                          Work, Fulfillment.Country, Destination.Country, 
                                          Destination.State, Qty, Retail.Price, 
                                          Manufacturers.Cut, Artists.Cut)
#Save basic Wrangled data
save(wrangled.data, file = "rda/wrangled-data.rda")

#Create adjusted data with daily mean and standard deviation
alpha = 0.05
daily.data.temp <- wrangled.data %>% 
  group_by(Date) %>%
  summarise(sales = sum(Artists.Cut), units = sum(Qty), mean.sales = 2, mean.units = 1.5, variation.sales = 1.1, growth.sales = NA, growth.units = NA)
daily.data.temp
daily.data <- data.frame(Date = seq(as.Date('2017-4-1'), as.Date(max(daily.data$Date)), 1), sales = 0, units = 0, mean.sales = 1, mean.units = 1, variation.sales = 1, growth.sales = NA, growth.units = NA)
daily.data
match(daily.data$Date[11], daily.data.temp$Date)

for (i in 2:nrow(daily.data)) {
  
  if(is.na(match(daily.data$Date[i], daily.data.temp$Date)))
  {
    daily.data$sales[i] = 0;
    daily.data$units[i] = 0;
  }
  
  else {
  daily.data$sales[i] = daily.data.temp$sales[match(daily.data$Date[i], daily.data.temp$Date)]
  daily.data$units[i] = daily.data.temp$units[match(daily.data$Date[i], daily.data.temp$Date)]
  }
      
  daily.data$mean.sales[i] = alpha*daily.data$sales[i-1] + (1-alpha)*daily.data$mean.sales[i-1]
  daily.data$mean.units[i] = alpha*daily.data$units[i-1] + (1-alpha)*daily.data$mean.units[i-1]
  
  if (daily.data$Date[i] > as.Date("2018-5-1"))
  {
    daily.data$growth.sales[i] = daily.data$mean.sales[i]/daily.data$mean.sales[i-365]
    daily.data$growth.units[i] = daily.data$mean.units[i]/daily.data$mean.units[i-365]
  }
  
  daily.data$variation.sales[i] = daily.data$sales[i]/daily.data$mean.sales[i-1]
}

daily.data <- daily.data  %>%
filter(Date >= '2017-5-1')

#Save daily
save(daily.data, file = "rda/daily-data.rda")
write.csv(daily.data, file = "data/daily-data.csv")

setwd(wd)
