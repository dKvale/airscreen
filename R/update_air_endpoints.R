
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
names(tox)[2] <- "Pollutant"

# Load subchronic
sub_chron <- read.csv("data\\subchronic_benchmarks.csv", header=T, colClasses=c("character"), stringsAsFactors=F, nrows=500, check.names=F)

# Load PBT and MDH ceiling value groups
category <- read.csv("data\\air_groups.csv", header=T, stringsAsFactors=F, nrows=500, check.names=F)

sub_chron <- cbind(sub_chron[ , c(1:2,5)], category[ , 3:5])

# Join endpoints
tox <- left_join(tox, sub_chron)

# Reorder columns
tox <- tox[ , c(1:3,5,4,6:8)]

# Clean names
names(tox)[3:5] <- c("Acute Toxic Endpoints", "Subchronic Toxic Endpoints", "Chronic Noncancer Endpoints")

names(tox) <- gsub(" ", "_", names(tox))

for(i in 6:8) {
  tox[ , i] <- ifelse(is.na(tox[ , i]), 0, tox[ , i])
  tox[ , i] <- ifelse(tox[ , i] == "X", 1, 0)
}

# Sort
tox <- arrange(tox, Pollutant)

# SAVE RESULTS
write.csv(tox, "data\\air_endpoints.csv", row.names = FALSE)


