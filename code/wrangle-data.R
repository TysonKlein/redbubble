library(tidyverse)

script.dir <- dirname(sys.frame(1)$ofile)
wd <- script.dir
setwd(wd)
setwd("..")

mean.and.sd <- read.csv("data/mean-and-sd.csv", header = FALSE)

mean.and.sd

mean.and.sd <- mean.and.sd %>% 
  mutate(mean = V1, sd = V2, day = as.numeric(rownames(mean.and.sd))) %>% 
  select(mean, sd, day)

save(mean.and.sd, file = "rda/mean-and-sd.rda")

setwd(wd)