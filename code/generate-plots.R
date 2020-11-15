library(readr)
library(ggplot2)
library(magrittr)
library(lubridate)
library(dplyr)
library(scales)  
require(reshape2)


#Set the path to be correctt
if (is.null(rstudioapi::getActiveDocumentContext()))
{
  script.dir <- dirname(sys.frame(1)$ofile)
  wd <- script.dir
  setwd(wd)
}else setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
setwd("..")

#Load the dataset for Daily plots
load(file = "rda/daily-data.rda")

#Set the plot theme for all following plots
plot.theme <- theme(axis.text.x=element_text(angle=60, hjust=1),
                    panel.background = element_rect(fill = "grey95"))

#Plot for Daily Sales
daily.sales.plot <- ggplot() + 
  geom_point(data = daily.data, colour = 'red', size = 3, alpha = 0.3, aes(x=Date, y = sales)) +
  scale_x_date(date_breaks = "1 month", date_labels =  "%b %Y", minor_breaks = "1 month") +
  scale_y_continuous(name = "Profit ($ CAD)", breaks = seq(0, (round(max(daily.data$sales-5)/10)+1)*10, 10)) +
  plot.theme
save(daily.sales.plot, file = "rda/daily-sales-plot.rda")
<<<<<<< HEAD
save(daily.sales.plot, file = "png/daily-sales-plot.png")
ggsave("png/daily-sales-plot.png", plot = daily.sales.plot)
=======
>>>>>>> 0a85e6c1827c25a83ca992410c8e8c03b80ea5c0

#Plot for Daily Sales + Mean sales + CI
daily.sales.plot.A <- ggplot() + 
  geom_point(data = daily.data, colour = 'red', size = 3, alpha = 0.3, aes(x=Date, y = sales)) +
  geom_line(data = daily.data, colour = 'red', size = 1.5, aes(x=Date, y = mean.sales)) +
  geom_line(data = daily.data, colour = 'red',alpha = 0.3, size = 1.5, aes(x=Date, y = sales.CI.upper)) +
  geom_line(data = daily.data, colour = 'red',alpha = 0.3, size = 1.5, aes(x=Date, y = sales.CI.lower)) +
  scale_x_date(date_breaks = "1 month", date_labels =  "%b %Y", minor_breaks = "1 month") +
  scale_y_continuous(name = "Profit ($ CAD)", breaks = seq(0, (round(max(daily.data$sales-5)/10)+1)*10, 10)) +
<<<<<<< HEAD
  annotate("segment", x = as.Date("2019-04-27"), xend = as.Date("2018-11-24"), y = 110, yend = 104, colour = "black", size=1, arrow=arrow()) +
  annotate("text", x = as.Date("2019-04-27"), y = 114, label = "Cyber Monday" , color="black", size=3 , fontface="bold") +
  annotate("segment", x = as.Date("2019-04-27"), xend = as.Date("2019-12-02"), y = 110, yend = 93, colour = "black", size=1, arrow=arrow()) +
  plot.theme
save(daily.sales.plot.A, file = "rda/daily-sales-plot-A.rda")
ggsave("png/daily-sales-plot-A.png", plot = daily.sales.plot.A)
=======
  annotate("segment", x = as.Date("2018-9-27"), xend = as.Date("2018-11-24"), y = 85, yend = 103, colour = "black", size=1, arrow=arrow()) +
  annotate("text", x = as.Date("2018-9-27"), y = 80, label = "Cyber Monday" , color="black", size=3 , fontface="bold") +
  plot.theme
save(daily.sales.plot.A, file = "rda/daily-sales-plot-A.rda")
>>>>>>> 0a85e6c1827c25a83ca992410c8e8c03b80ea5c0

#Plot for Daily Users
daily.users.plot <- ggplot() + 
  geom_point(data = daily.data, colour = 'turquoise 4', size = 3, alpha = 0.3, aes(x=Date, y = users)) +
  scale_x_date(date_breaks = "1 month", date_labels =  "%b %Y", minor_breaks = "1 month") +
  scale_y_continuous(name = "Users", breaks = seq(0, (round(max(daily.data$users-5)/10)+1)*10, 10)) +
  plot.theme
save(daily.users.plot, file = "rda/daily-users-plot.rda")
<<<<<<< HEAD
ggsave("png/daily-users-plot.png", plot = daily.users.plot)
=======
>>>>>>> 0a85e6c1827c25a83ca992410c8e8c03b80ea5c0

#Plot for Daily Users adjusted
daily.users.adjusted.plot <- ggplot() + 
  geom_point(data = daily.data, colour = 'turquoise 4', size = 3, alpha = 0.3, aes(x=Date, y = users/mean.users)) +
  scale_x_date(date_breaks = "1 month", date_labels =  "%b %Y", minor_breaks = "1 month") +
  scale_y_continuous(name = "Adjusted Users") +
  plot.theme
save(daily.users.adjusted.plot, file = "rda/daily-users-adjusted-plot.rda")

#Plot for Daily Users + Mean users + CI
daily.users.plot.A <- ggplot() + 
  geom_point(data = daily.data, colour = 'turquoise 4', size = 3, alpha = 0.3, aes(x=Date, y = users)) +
  geom_line(data = daily.data, colour = 'turquoise 4', size = 1.5, aes(x=Date, y = mean.users)) +
  geom_line(data = daily.data, colour = 'turquoise 4',alpha = 0.3, size = 1.5, aes(x=Date, y = users.CI.upper)) +
  geom_line(data = daily.data, colour = 'turquoise 4',alpha = 0.3, size = 1.5, aes(x=Date, y = users.CI.lower)) +
  scale_x_date(date_breaks = "1 month", date_labels =  "%b %Y", minor_breaks = "1 month") +
  scale_y_continuous(name = "Users", breaks = seq(0, (round(max(daily.data$users-5)/10)+1)*10, 10)) +
  plot.theme
save(daily.users.plot.A, file = "rda/daily-users-plot-A.rda")

#Plot for Daily orders + mean orders
daily.orders.plot <- ggplot() + 
  geom_point(data = daily.data, colour = 'orange 4', size = 3, alpha = 0.3, aes(x=Date, y = orders)) +
  geom_line(data = daily.data, colour = 'orange 4', size = 1.5, aes(x=Date, y = mean.orders)) +
  scale_x_date(date_breaks = "1 month", date_labels =  "%b %Y", minor_breaks = "1 month") +
  scale_y_continuous(name = "Orders", breaks = seq(0, (round(max(daily.data$orders-5)/10)+1)*10, 10)) +
  plot.theme
save(daily.orders.plot, file = "rda/daily-orders-plot.rda")

#Plot for Daily units + mean units
daily.units.plot <- ggplot() + 
  geom_point(data = daily.data, colour = 'blue', size = 3, alpha = 0.3, aes(x=Date, y = units)) +
  geom_line(data = daily.data, colour = 'blue', size = 1.5, aes(x=Date, y = mean.units)) +
  scale_x_date(date_breaks = "1 month", date_labels =  "%b %Y", minor_breaks = "1 month") +
  scale_y_continuous(name = "units", breaks = seq(0, (round(max(daily.data$units-5)/10)+1)*10, 10)) +
  plot.theme
save(daily.units.plot, file = "rda/daily-units-plot.rda")

#Plot for Daily $ per Order
daily.dollar.per.order.plot <- ggplot() + 
  geom_line(data = daily.data, colour = "purple", size = 1.5, aes(x=Date, y = mean.sales/mean.orders)) +
  scale_x_date(date_breaks = "1 month", date_labels =  "%b %Y", minor_breaks = "1 month") +
  scale_y_continuous(name = "Profit per Order", breaks = seq(0, 3, 0.5)) +
  expand_limits(y = 0) +
  plot.theme
save(daily.dollar.per.order.plot, file = "rda/daily-dollar-per-order-plot.rda")

#Plot for Daily $ per Order
daily.dollar.per.user.plot <- ggplot() + 
  geom_line(data = daily.data, colour = "purple", size = 1.5, aes(x=Date, y = mean.sales/mean.users)) +
  scale_x_date(date_breaks = "1 month", date_labels =  "%b %Y", minor_breaks = "1 month") +
  scale_y_continuous(name = "Profit per Order", breaks = seq(0, 3, 0.5)) +
  expand_limits(y = 0) +
  plot.theme
daily.dollar.per.user.plot

#Plot for Daily Orders per User
daily.order.per.user.plot <- ggplot() + 
  geom_line(data = daily.data, colour = "turquoise 4", size = 1.5, aes(x=Date, y = mean.orders/mean.users)) +
  scale_x_date(date_breaks = "1 month", date_labels =  "%b %Y", minor_breaks = "1 month") +
  scale_y_continuous(name = "Orders per User", breaks = seq(0, 1, 0.1)) +
  expand_limits(y = 0) +
  plot.theme
save(daily.order.per.user.plot, file = "rda/daily-order-per-user-plot.rda")

#Plot for Daily Units per Order
daily.units.per.order.plot <- ggplot() + 
  geom_line(data = daily.data, colour = "blue 4", size = 1.5, aes(x=Date, y = mean.units/mean.orders)) +
  scale_x_date(date_breaks = "1 month", date_labels =  "%b %Y", minor_breaks = "1 month") +
  scale_y_continuous(name = "Units per Order", breaks = seq(1, 1.5, 0.1)) +
  expand_limits(y = 1) +
  plot.theme
save(daily.units.per.order.plot, file = "rda/daily-units-per-order-plot.rda")

#Plot for units per order histogram
load(file = "rda/order-data.rda")
units.per.order.hist <- ggplot(order.data %>% filter(units < 10), aes(x = as.character(units))) +
  geom_bar() +
  xlab("Units in Order") + 
  ylab("Orders") +
  plot.theme + 
  theme(axis.text.x=element_text(angle=0))
save(units.per.order.hist, file = "rda/units-per-order-hist.rda")

#Plot for unit profit histogram
load(file = "rda/discounts.rda")
load(file = "rda/price-stratified.rda")
unit.profit.hist <- ggplot(,aes(x = price.stratified$Artists.Cut)) + 
  geom_histogram(binwidth = 0.01) + 
  xlab("Profit per Unit") + 
  ylab("") +
  scale_x_continuous(breaks = seq(2, 4.25, 0.25),labels = dollar_format(prefix = "$"))
save(unit.profit.hist, file = "rda/unit-profit-hist.rda")
  
#Plot for unit profit histogram with discounts
unit.profit.hist.with.discount <- ggplot(,aes(x = price.stratified$Artists.Cut)) + 
  geom_histogram(binwidth = 0.01) + 
  xlab("Profit per Unit") + 
  ylab("") +
  geom_vline(data = discounts, xintercept = discounts$cost,size = 1.1,alpha = 0.6, color = colorRampPalette(c("blue", "red"))(nrow(discounts))) +
  geom_text(data = discounts, label = discounts$percent, y = 135,x = discounts$cost + 0.03, colour = colorRampPalette(c("blue", "red"))(nrow(discounts)), size = 4, angle = 90) +
  scale_x_continuous(breaks = seq(2, 4.25, 0.25),labels = dollar_format(prefix = "$"))
save(unit.profit.hist.with.discount, file = "rda/unit-profit-hist-with-discount.rda")

