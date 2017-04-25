# Update the pollutant endpoints using the most recent RASS table
library(RODBC)
library(dplyr)
library(readr)
library(stringr)


rass <- read_excel("X:/Agency_Files/Outcomes/Risk_Eval_Air_Mod/_Air_Risk_Evaluation/AERA program/RASS/AERA RASS (aq9-22-7) - April 2017.xlsx", 7, skip = 18)

rass <- rass[ , -c(1,2)]

names(rass)[c(1,2)] <- c("CAS","Pollutant")

rass$CAS       <- str_trim(rass$CAS)

rass$Pollutant <- str_trim(rass$Pollutant)

tox  <- rass[1:grep("Ethyl Acetate", rass$Pollutant), c(1:2,6,19,26)]

# Clean names
names(tox)[3:5] <- c("Acute Toxic Endpoints", "Subchronic Toxic Endpoints", "Chronic Noncancer Endpoints")
#names(tox) <- gsub(" ", "_", names(tox))

tox <- filter(tox, !is.na(Pollutant))



# Load current benchmark table
fscreen <- read_csv("https://raw.githubusercontent.com/dKvale/fair-screen/master/data/air_benchmarks.csv")


# Join to endpoints to benchmark pollutants
endpts  <- left_join(fscreen[ , 1:2], tox)


# Load subchronic
#sub_chron <- read.csv("data\\subchronic_benchmarks.csv", header=T, colClasses=c("character"), stringsAsFactors=F, nrows=500, check.names=F)


# Load PBT and MDH ceiling value groups
category  <- read.csv("data\\air_groups.csv", header = T, stringsAsFactors = F, check.names = F)


# Join subchronic
#tox <- left_join(tox, sub_chron[, c(1,5)], by = 'CAS')


# Join to endpoints
endpts <- left_join(endpts,  category[ , c(1,3:5)], by = 'CAS')

# Reorder columns
tox <- endpts[ , c(1:3,5,4,6:8)]


for(i in 6:8) {
  tox[ , i] <- ifelse(is.na(tox[ , i]), 0, tox[ , i])
  tox[ , i] <- ifelse(tox[ , i] == "X", 1, 0)
}

# Sort
tox <- arrange(tox, Pollutant)

# SAVE RESULTS
write.csv(tox, "data\\air_endpoints.csv", row.names = FALSE)


