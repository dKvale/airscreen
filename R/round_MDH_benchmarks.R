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
risks   <- left_join(unrounded, refs)


# Round MDH cancer values
mdh <- filter(risks[ , -c(1,3:5)], `Cancer IHB Reference` %in% c("HRV","HBV")) #"MDH","MPCA","MPCA/MDH"))


risks_1 <- risks %>%
           mutate(`Chronic cancer risk of 1E-5 Air Conc (ug/m3)` = ifelse(`Cancer IHB Reference` %in% c("HRV","HBV"), #"MDH","MPCA","MPCA/MDH"), 
                                                                          signif(`Chronic cancer risk of 1E-5 Air Conc (ug/m3)`, 1), 
                                                                          `Chronic cancer risk of 1E-5 Air Conc (ug/m3)`))


changed <- risks_1[abs(risks_1$`Chronic cancer risk of 1E-5 Air Conc (ug/m3)` - risks$`Chronic cancer risk of 1E-5 Air Conc (ug/m3)`) > 0, ]


# Update benzene to 2 significant figures
risks_1[risks_1$Pollutant == "Benzene", ]$`Chronic cancer risk of 1E-5 Air Conc (ug/m3)` <- 1.3

# SAVE
write_csv(risks_1[ , 1:6], "data/air_benchmarks.csv")


# Join to RASS table for copy/pasting
rass <- read_excel("X:/Agency_Files/Outcomes/Risk_Eval_Air_Mod/_Air_Risk_Evaluation/AERA program/RASS/AERA RASS (aq9-22-7) - April 2017.xlsx", 7, skip = 18)

rass <- rass[ , -c(1,2)]

rass <- rass[ , -c(3,4,6:12,14:17,19:24,26:32)]

names(rass)[1] <- "CAS"

rass$CAS <- str_trim(rass$CAS)

rass     <- filter(rass[1:grep("Zinc chromate", rass$`Chemical Name`), 1:5], !is.na(CAS))

# Join rounded values
risks_1$cas_check  <- "x" 

new_rass <- left_join(rass, risks_1[ , c(1:6, ncol(risks_1))])

write_csv(new_rass, "../Rounded IHBs for RASS spreadsheet.csv", na = "")

##
