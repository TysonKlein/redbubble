library(fitdistrplus)#for distribution fitting
library(VGAM)#for dagum functions
library(SpatialExtremes)#for gev functions

script.dir <- dirname(sys.frame(1)$ofile)
setwd(script.dir)
setwd("..")

load(file = "rda/daily-data.rda")

fitting.sample <- daily.data$units/daily.data$mean.units #Selecting the sample required for fitting a distribution
fitting.sample[fitting.sample == 0] <- 0.0000001 #Removing 0 values and replacing them with practically identical ones
#This is required to fit the gamma distribution

#Fitting the 5 possible preselected distributions
fit.norm <- fitdist(fitting.sample, distr = "norm", method = "mge")
fit.gamma <- fitdist(fitting.sample, distr = "gamma", lower = c(0,0), method = "mge")
fit.weibull <- fitdist(fitting.sample, distr = "weibull", lower = c(0,0), method = "mge")
fit.dagum <- fitdist(fitting.sample, distr = "dagum", start = list(scale = 1, shape1.a = 1, shape2.p = 1), method = 'mge')
fit.gev <- fitdist(fitting.sample, distr = "gev", start = list(loc = 0, scale = 1, shape =0), method = "mge")

#Performing a Kolmogorov-Smirnov fitness test for all possible distributions
ks.test.norm <- ks.test(fitting.sample, "pnorm", mean = fit.norm$estimate["mean"], sd = fit.norm$estimate["sd"])
ks.test.gamma <- ks.test(fitting.sample, "pgamma", shape = fit.gamma$estimate["shape"], rate = fit.gamma$estimate["rate"])
ks.test.weibull <- ks.test(fitting.sample, "pweibull", shape = fit.weibull$estimate["shape"], scale = fit.weibull$estimate["scale"])
ks.test.dagum <- ks.test(fitting.sample, "pdagum", scale = fit.dagum$estimate["scale"], shape1.a = fit.dagum$estimate["shape1.a"], shape2.p = fit.dagum$estimate["shape2.p"])
ks.test.gev <-  ks.test(fitting.sample, "pgev", loc = fit.gev$estimate["loc"], scale = fit.gev$estimate["scale"], shape = fit.gev$estimate["shape"])

ks.results <- data.frame("Distribution" = 
                           c("Normal", "Gamma", "Weibull", "Dagum", "GEV"),
                         "Test Statistic" = 
                           c(ks.test.norm$statistic, ks.test.gamma$statistic, ks.test.weibull$statistic, ks.test.dagum$statistic, ks.test.gev$statistic),
                         "P-value" = 
                           c(ks.test.norm$p.value, ks.test.gamma$p.value, ks.test.weibull$p.value, ks.test.dagum$p.value, ks.test.gev$p.value))
ks.results

save(fit.dagum, file = "rda/best-model.rda")
# Compare fits 

  par(mfrow = c(2, 2))
fits <- list(fit.norm, fit.gamma, fit.weibull, fit.dagum, fit.gev)
plot.legend <- c("Normal", "Gamma", "Weibull", "Dagum", "GEV")
plot.colours <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

denscomp(fits, fitcol = plot.colours, legendtext = plot.legend)
qqcomp(fits, fitcol = plot.colours, legendtext = plot.legend)
cdfcomp(fits, fitcol = plot.colours, legendtext = plot.legend)
ppcomp(fits, fitcol = plot.colours, legendtext = plot.legend)

setwd(script.dir)
