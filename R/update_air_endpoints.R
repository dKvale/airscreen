
library(RODBC)
library(dplyr)
library(readr)
library(stringr)


risk_connect <- odbcConnectAccess2007("X:\\Programs\\Air_Quality_Programs\\Air Monitoring Data and Risks\\4 Concentration to Risk Estimate Database\\Air Toxics Risks Estimates.accdb")

# Get data from a table or query in the database
risk_vals <- sqlQuery(risk_connect, paste ("select * from [Toxicity]"), stringsAsFactors=F)

odbcCloseAll()

risk_vals[ ,4] <- str_trim(gsub("\xca","", risk_vals[,4]))
risk_vals[ ,5] <- str_trim(gsub("\xca","", risk_vals[,5]))


tox <- risk_vals[ , c(4:5,9,22)]

# Load subchronic
sub_chron <- read.csv("data\\subchronic_benchmarks.csv", header=T, stringsAsFactors=F, nrows=500, check.names=F)

# Join endpoints
tox <- left_join(tox, sub_chron[ , c(1,5)])

# Reorder columns
tox <- tox[ , c(1:3,5,4)]

# Clean names
names(tox) <- c("CAS#", "Pollutant", "Acute Toxic Endpoints", "Subchronic Toxic Endpoints", "Chronic Non-cancer Endpoints")

# Load PBT and MDH ceiling value groups
category <- read.csv("data\\air_groups_PBTs.csv", header=T, stringsAsFactors=F, nrows=500, check.names=F)

for(i in 3:6) {
  category[ , i] <- category[ , i] == "X"
}

category[ ,1] <- str_trim(gsub("\xca","", category[,1]))
category[ ,2] <- str_trim(gsub("\xca","", category[,2]))

# Join category
tox <- left_join(tox, category)

# Sort
tox <- arrange(tox, Pollutant)

# SAVE RESULTS
write.csv(tox, "data\\air_endpoints.csv", row.names = FALSE)


