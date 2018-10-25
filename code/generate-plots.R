library(readr)
library(ggplot2)
library(magrittr)
library(lubridate)
library(dplyr)
library(VGAM)
require(reshape2)

script.dir <- dirname(sys.frame(1)$ofile)
setwd(script.dir)
setwd("..")

#First, generate the daily plots
load(file = "rda/daily-data.rda")
load("rda/best-model.rda")

daily.data <- daily.data %>%
  mutate(units.CI.upper = mean.units*qdagum(0.1, scale = fit.dagum$estimate["scale"], shape1.a = fit.dagum$estimate["shape1.a"], shape2.p = fit.dagum$estimate["shape2.p"]),
         units.CI.lower = mean.units*qdagum(0.9, scale = fit.dagum$estimate["scale"], shape1.a = fit.dagum$estimate["shape1.a"], shape2.p = fit.dagum$estimate["shape2.p"]),
         sales.CI.upper = mean.sales*qdagum(0.1, scale = fit.dagum$estimate["scale"], shape1.a = fit.dagum$estimate["shape1.a"], shape2.p = fit.dagum$estimate["shape2.p"]),
         sales.CI.lower = mean.sales*qdagum(0.9, scale = fit.dagum$estimate["scale"], shape1.a = fit.dagum$estimate["shape1.a"], shape2.p = fit.dagum$estimate["shape2.p"]))

daily.sales.plot <- ggplot() + 
  geom_point(data = daily.data, colour = 'red', size = 3, alpha = 0.3, aes(x=Date, y = sales)) +
  geom_line(data = daily.data, colour = 'red', size = 1.5, aes(x=Date, y = mean.sales)) +
  geom_line(data = daily.data, colour = 'red',alpha = 0.3, size = 1.5, aes(x=Date, y = sales.CI.upper)) +
  geom_line(data = daily.data, colour = 'red',alpha = 0.3, size = 1.5, aes(x=Date, y = sales.CI.lower)) +
  scale_x_date(date_breaks = "1 month", date_labels =  "%b %Y", minor_breaks = "1 month") +
  scale_y_continuous(name = "$CAD", breaks = seq(0, (round(max(daily.data$sales-5)/10)+1)*10, 10)) +
  theme(axis.text.x=element_text(angle=60, hjust=1))
save(daily.sales.plot, file = "rda/daily-sales-plot.rda")

daily.units.plot <- ggplot() + 
  geom_point(data = daily.data, colour = 'blue', size = 3, alpha = 0.3, aes(x=Date, y = units)) +
  geom_line(data = daily.data, colour = 'blue', size = 1.5, aes(x=Date, y = mean.units)) +
  geom_line(data = daily.data, colour = 'blue',alpha = 0.3, size = 1.5, aes(x=Date, y = units.CI.upper)) +
  geom_line(data = daily.data, colour = 'blue',alpha = 0.3, size = 1.5, aes(x=Date, y = units.CI.lower)) +
  scale_x_date(date_breaks = "1 month", date_labels =  "%b %Y", minor_breaks = "1 month") +
  scale_y_continuous(name = "units", breaks = seq(0, (round(max(daily.data$units-5)/10)+1)*10, 10)) +
  theme(axis.text.x=element_text(angle=60, hjust=1))
save(daily.units.plot, file = "rda/daily-units-plot.rda")

daily.dollar.per.sale.plot <- ggplot() + 
  geom_line(data = daily.data, colour = "turquoise 4", size = 1.5, aes(x=Date, y = mean.sales/mean.units)) +
  scale_x_date(date_breaks = "1 month", date_labels =  "%b %Y", minor_breaks = "1 month") +
  scale_y_continuous(name = "$ Cad per unit", breaks = seq(0, 3, 0.5)) +
  expand_limits(y = 0) +
  theme(axis.text.x=element_text(angle=60, hjust=1))
save(daily.dollar.per.sale.plot, file = "rda/daily-dollar-per-sale-plot.rda")

#Generate the binned monthly sales plot
load(file = "rda/redbubble-MC-forecast.rda")

realMonths <- c(166.48, 274.25, 320.98, 453.91, 344.39, 340.81,
                465.41, 536.69, 326.99, 280.21, 303.37, 298.61,
                357.58, 512.02, 778.18, 843.55, 787.08, 325.93)
numRealMonths <- round(length(realMonths))
realMonths <- as.data.frame(t(realMonths))
names(realMonths) <-format(single$month[seq(1, numRealMonths, 1)],"%b%y")

col_names <- colnames(realMonths)
bigger <- data.frame(1)
for (i in 1:ncol(realMonths)) {
bigger[i] <-  sum(redbubble.MC.forecast[,col_names[i]]<realMonths[,col_names[i]])/nrow(redbubble.MC.forecast)
}
names(bigger) <-names(realMonths)
melted <- melt(bigger)

redbubble.MC.forecast[,ncol(redbubble.MC.forecast)] <- NULL

MC.boxPlot <- ggplot() + 
  geom_boxplot(data = melt(redbubble.MC.forecast), aes(x=variable, y = value), fill="slateblue", alpha=0.2) +
  geom_point(data = melt(realMonths), colour = 'red', size = 2, aes(x=variable, y = value)) +
  geom_text(data = melted, aes(x=variable, y=10),label = round(100*melted$value)) +
  scale_y_continuous(breaks = round(seq(0, max(results), by = 100),2)) +
  theme(axis.text.x=element_text(angle=60, hjust=1))
MC.boxPlot
  
save(MC.boxPlot, file = "rda/MC-boxPlot.rda")
