library(readr)
library(ggplot2)
library(magrittr)
library(lubridate)
library(dplyr)
require(reshape2)

script.dir <- dirname(sys.frame(1)$ofile)
setwd(script.dir)
setwd("..")

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
  geom_text(data = melted, aes(x=variable, y=10),label = round(100*melted$value))
  scale_y_continuous(breaks = round(seq(0, max(results), by = 100),2))
  
MC.boxPlot  
save(MC.boxPlot, file = "rda/MC-boxPlot.rda")