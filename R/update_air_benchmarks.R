
library(RODBC)
library(dplyr)
library(readr)
library(stringr)

options(scipen=+9999, digits=15)

risk_connect <- odbcConnectAccess2007("X:\\Programs\\Air_Quality_Programs\\Air Monitoring Data and Risks\\4 Concentration to Risk Estimate Database\\Air Toxics Risks Estimates.accdb")

# Get data from a table or query in the database
risk_vals <- sqlQuery(risk_connect, paste ("select * from [Toxicity]"), stringsAsFactors=F)
odbcCloseAll()

risk_vals[ ,4] <- str_trim(gsub("\xca","", risk_vals[,4]))
risk_vals[ ,5] <- str_trim(gsub("\xca","", risk_vals[,5]))

HBVs <- risk_vals[ , c(4:5,8,16,21)]
names(HBVs)[2] <- "Pollutant"

# Load subchronic
sub_chron <- read.csv("data\\subchronic_benchmarks.csv", header=T,  stringsAsFactors=F, nrows=500, check.names=F)

sub_chron[ ,1] <- str_trim(gsub("\xca","", sub_chron[,1]))
sub_chron[ ,2] <- str_trim(gsub("\xca","", sub_chron[,2]))

# Join risk values
HBVs <- full_join(HBVs, sub_chron[ , c(1,2,4)])

# Remove duplicates
HBVs <- unique(HBVs)

# Reorder columns
HBVs <- HBVs[ , c(1,2,3,6,5,4)]

# Clean names
names(HBVs) <- c("CAS", 
                 "Pollutant", 
                 "Acute Reference Conc (ug/m3)", 
                 "Subchronic Non-cancer Reference Conc (ug/m3)", 
                 "Chronic Non-cancer Reference Conc (ug/m3)", 
                 "Chronic cancer risk of 1E-5 Air Conc (ug/m3)")

HBVs <- arrange(HBVs, Pollutant)

# Round to significant digits
HBVs[ , 4] <- signif(HBVs[ , 4] , 2)
HBVs[ , 5] <- signif(HBVs[ , 5] , 2)
HBVs[ , 6] <- signif(HBVs[ , 6] , 2)

# SAVE RESULTS
write.csv(HBVs, "data\\air_benchmarks.csv", row.names = FALSE)


