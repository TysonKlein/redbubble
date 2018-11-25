library(fitdistrplus)#for distribution fitting
library(VGAM)#for dagum functions
library(SpatialExtremes)#for gev functions

#Setting the correct path
if (is.null(rstudioapi::getActiveDocumentContext()))
{
  script.dir <- dirname(sys.frame(1)$ofile)
  wd <- script.dir
  setwd(wd)
}else
{
  setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
}
setwd("..")

#Load in the most recent data to analyze
load(file = "rda/daily-data.rda")

#Selecting the sample required for fitting a distribution
fitting.sample <- daily.data$users/daily.data$mean.users
#this can also be done for Sales, orders or units with similar results

#Removing 0 values and replacing them with practically identical ones
fitting.sample[fitting.sample == 0] <- 0.0001
#This is required to fit some distributions

#Fitting the 5 possible preselected distributions, as determined by familiarity
fit.norm <- fitdist(fitting.sample, distr = "norm", method = "mge")
fit.gamma <- fitdist(fitting.sample, distr = "gamma", lower = c(0,0), method = "mge")
fit.weibull <- fitdist(fitting.sample, distr = "weibull", lower = c(0,0), method = "mge")
fit.dagum <- fitdist(fitting.sample, distr = "dagum", start = list(scale = 1, shape1.a = 1, shape2.p = 1), method = 'mge')
fit.gev <- fitdist(fitting.sample, distr = "gev", start = list(loc = 1, scale = 0.25, shape =1), method = "mge")

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
#Results for the Kolmogorov-Smirnov fitness tests
ks.results
save(ks.results, file = "rda/ks-tests-users.rda")
save(fit.dagum, file = "rda/best-fit-dist-users.rda")

# Compare fits 
fits.users <- list(fit.norm, fit.gamma, fit.weibull, fit.dagum, fit.gev)

#Save fits for Users, can also be done for other factors
save(fits.users, file = "rda/fitted-distributions-users.rda")
