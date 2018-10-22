library(tidyverse)
library(lubridate)

script.dir <- dirname(sys.frame(1)$ofile)
wd <- script.dir
setwd(wd)
setwd("..")

select <- dplyr::select

#load Data from csv file
artist.sales.report <- read.csv("data/artist-sales-report.csv", header = TRUE)

wrangled.data <- artist.sales.report %>%
  mutate(Date = as.Date(Order.Date, origin="1899-12-30"))

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

head(wrangled.data)

#Create adjusted data with daily mean and standard deviation
alpha = 0.07
daily.data <- wrangled.data %>% 
  group_by(Date) %>%
  summarise(sales = sum(Artists.Cut), units = sum(Qty), mean.sales = 1, sd.sales = 1, mean.units = 1, sd.units = 1, variation.sales = 1)

for (i in 2:nrow(daily.data)) {
  daily.data$mean.sales[i] = alpha*daily.data$sales[i] + (1-alpha)*daily.data$mean.sales[i-1]
  daily.data$mean.units[i] = alpha*daily.data$units[i] + (1-alpha)*daily.data$mean.units[i-1]
  
  if (i > 30)
  {
    daily.data$sd.sales[i] = 0.3*sd(daily.data$sales[(i-30):i]) + 0.3*sd(daily.data$sales[(i-20):i]) + 0.3*sd(daily.data$sales[(i-10):i]) + 0.1*sd(daily.data$sales[(i-5):i])
    daily.data$sd.units[i] = 0.3*sd(daily.data$units[(i-30):i]) + 0.3*sd(daily.data$units[(i-20):i]) + 0.3*sd(daily.data$units[(i-10):i]) + 0.1*sd(daily.data$units[(i-5):i])
  }
  else
  {
    daily.data$sd.sales[i] = sd(daily.data$sales[i:(i+5)])
    daily.data$sd.units[i] = sd(daily.data$units[i:(i+5)])
  }
  
  daily.data$variation.sales[i] = daily.data$sales[i]/daily.data$mean.sales[i-1]
}

daily.data <- daily.data  %>%
filter(Date > '2017-5-1')

daily.data

#Save daily
save(daily.data, file = "rda/daily-data.rda")

setwd(wd)