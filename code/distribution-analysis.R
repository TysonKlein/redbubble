library(fitdistrplus)

script.dir <- dirname(sys.frame(1)$ofile)
setwd(script.dir)
setwd("..")

load(file = "rda/daily-data.rda")

fit.weibull <- fitdist(daily.data$variation.sales, "weibull")
fit.gamma <- fitdist(daily.data$variation.sales, "gamma", lower = c(0, 0))

# Compare fits 

par(mfrow = c(2, 2))
plot.legend <- c("Weibull", "Gamma")
denscomp(list(fit.weibull, fit.gamma), fitcol = c("red", "blue"), legendtext = plot.legend)
qqcomp(list(fit.weibull, fit.gamma), fitcol = c("red", "blue"), legendtext = plot.legend)
cdfcomp(list(fit.weibull, fit.gamma), fitcol = c("red", "blue"), legendtext = plot.legend)
ppcomp(list(fit.weibull, fit.gamma), fitcol = c("red", "blue"), legendtext = plot.legend)

setwd(script.dir)