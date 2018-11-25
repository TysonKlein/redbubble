library(readr)
library(ggplot2)
library(magrittr)
library(lubridate)
library(dplyr)
require(reshape2)


#Set the path to be correctt
if (is.null(rstudioapi::getActiveDocumentContext()))
{
  script.dir <- dirname(sys.frame(1)$ofile)
  wd <- script.dir
  setwd(wd)
}else setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
setwd("..")

tail(daily.data)

#First, generate the daily plots
load(file = "rda/daily-data.rda")

#Set the plot theme for all following plots
plot.theme <- theme(axis.text.x=element_text(angle=60, hjust=1),
                    panel.background = element_rect(fill = "grey95"))

#Plot for Daily Sales
daily.sales.plot <- ggplot() + 
  geom_point(data = daily.data, colour = 'red', size = 3, alpha = 0.3, aes(x=Date, y = sales)) +
  scale_x_date(date_breaks = "1 month", date_labels =  "%b %Y", minor_breaks = "1 month") +
  scale_y_continuous(name = "$CAD", breaks = seq(0, (round(max(daily.data$sales-5)/10)+1)*10, 10)) +
  plot.theme
save(daily.sales.plot, file = "rda/daily-sales-plot.rda")

#Plot for Daily Sales + Mean sales + CI
daily.sales.plot.A <- ggplot() + 
  geom_point(data = daily.data, colour = 'red', size = 3, alpha = 0.3, aes(x=Date, y = sales)) +
  geom_line(data = daily.data, colour = 'red', size = 1.5, aes(x=Date, y = mean.sales)) +
  geom_line(data = daily.data, colour = 'red',alpha = 0.3, size = 1.5, aes(x=Date, y = sales.CI.upper)) +
  geom_line(data = daily.data, colour = 'red',alpha = 0.3, size = 1.5, aes(x=Date, y = sales.CI.lower)) +
  scale_x_date(date_breaks = "1 month", date_labels =  "%b %Y", minor_breaks = "1 month") +
  scale_y_continuous(name = "$CAD", breaks = seq(0, (round(max(daily.data$sales-5)/10)+1)*10, 10)) +
  plot.theme
save(daily.sales.plot.A, file = "rda/daily-sales-plot-A.rda")

#Plot for Daily Users
daily.users.plot <- ggplot() + 
  geom_point(data = daily.data, colour = 'turquoise 4', size = 3, alpha = 0.3, aes(x=Date, y = users)) +
  scale_x_date(date_breaks = "1 month", date_labels =  "%b %Y", minor_breaks = "1 month") +
  scale_y_continuous(name = "Users", breaks = seq(0, (round(max(daily.data$users-5)/10)+1)*10, 10)) +
  plot.theme
save(daily.users.plot, file = "rda/daily-users-plot.rda")

#Plot for Daily Users normalized
daily.users.normalized.plot <- ggplot() + 
  geom_point(data = daily.data, colour = 'turquoise 4', size = 3, alpha = 0.3, aes(x=Date, y = users/mean.users)) +
  scale_x_date(date_breaks = "1 month", date_labels =  "%b %Y", minor_breaks = "1 month") +
  scale_y_continuous(name = "Normalized Users") +
  plot.theme
save(daily.users.normalized.plot, file = "rda/daily-users-normalized-plot.rda")

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
  scale_y_continuous(name = "$ Cad per Order", breaks = seq(0, 3, 0.5)) +
  expand_limits(y = 0) +
  plot.theme
save(daily.dollar.per.order.plot, file = "rda/daily-dollar-per-order-plot.rda")

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
