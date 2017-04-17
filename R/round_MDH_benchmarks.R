# Round MDH benchmarks to 1 significant digit
library(tidyverse)
library(readxl)
library(stringr)


# Load risk values
risks     <- read_csv("https://raw.githubusercontent.com/dKvale/fair-screen/master/data/air_benchmarks.csv")

unrounded <- read_csv("data/unrounded_MDH_risk_values.csv")

# Load references
refs      <- read_csv("data/air_benchmark_references.csv")


# Join
risks   <- left_join(risks, refs)


# Round MDH cancer values
mdh <- filter(risks, `Cancer IHB Reference` %in% c("MDH","HRV","HBV","MPCA","MPCA/MDH"))


risks_1 <- risks %>%
           mutate(`Chronic cancer risk of 1E-5 Air Conc (ug/m3)` = ifelse(`Cancer IHB Reference` %in% c("MDH","HRV","HBV","MPCA","MPCA/MDH"), 
                                                                          signif(`Chronic cancer risk of 1E-5 Air Conc (ug/m3)`, 1), 
                                                                          `Chronic cancer risk of 1E-5 Air Conc (ug/m3)`))


changed <- risks_1[abs(risks_1$`Chronic cancer risk of 1E-5 Air Conc (ug/m3)` - risks$`Chronic cancer risk of 1E-5 Air Conc (ug/m3)`) > 0, ]


# Update benzene to 2 significant figures
risks_1[risks_1$Pollutant == "Benzene", ]$`Chronic cancer risk of 1E-5 Air Conc (ug/m3)` <- 1.3

# SAVE
write_csv(risks_1[ , 1:6], "data/air_benchmarks.csv")



##
