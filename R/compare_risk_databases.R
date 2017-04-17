library(RODBC)
library(dplyr)
library(stringr)
library(readxl)
library(readr)

risk_connect <- odbcConnectAccess2007("X:\\Programs\\Air_Quality_Programs\\Air Monitoring Data and Risks\\4 Concentration to Risk Estimate Database\\Air Toxics Risks Estimates_update2015.accdb")

# Get data table or query in the database
risk_vals <- sqlQuery(risk_connect, paste("select * from [Toxicity]"), stringsAsFactors=F)

rm(risk_connect)

odbcCloseAll()

# Clean white space & special characters
#risk_vals[ , 4] <- str_trim(gsub("\xca","", risk_vals[ , 4]))
#risk_vals[ , 5] <- str_trim(gsub("\xca","", risk_vals[ , 5]))


# Filter and clean
risk_vals <- risk_vals[ , c(4,5,8,16,21)]

names(risk_vals)[1] <- "CAS"
names(risk_vals)[2] <- "Pollutant"

risk_vals$CAS <- str_trim(risk_vals$CAS)

risk_vals <- filter(risk_vals, !is.na(CAS))
##################

rass <- read_excel("X:/Agency_Files/Outcomes/Risk_Eval_Air_Mod/_Air_Risk_Evaluation/AERA program/RASS/AERA RASS (aq9-22-7) - April 2017.xlsx", 7, skip = 18)

rass <- rass[ , -c(1,2)]

#rass[ , 1] <- str_trim(gsub("\xca","", rass[ , 1]))
#rass[ , 2] <- str_trim(gsub("\xca","", rass[ , 2]))

#rass[ , 2] <- str_trim(gsub("ÿ","", rass[ , 2]))
#rass[ , 1] <- str_trim(gsub("ÿ","", rass[ , 1]))

names(rass)[1] <- "CAS"

rass$CAS <- str_trim(rass$CAS)

risks <- left_join(rass[ , -c(3,4,6:12,14:17,19:24,26:32)], risk_vals)

rm(rass)
rm(risk_vals)

names(risks) <- c("CAS","Pollutant", 
                  "AcuteConc","CancerConc",
                  "NoncancerConc", "NonCancer_rass",
                  "Pollutant_rass", "Acute_rass",
                  "Cancer_rass","Subchron_rass") 

risks <- risks[,c(1,2,3,6,4,7,5,8)]

# Find tox value differences
risks_comp <- mutate(risks, 
                     acute_test     = abs(AcuteConc - Acute_HBV) <   Acute_HBV * .01,
                     cancer_test    = abs(CancerConc - Cancer_HBV) <   Cancer_HBV * .01,
                     nonCancer_test = abs(NoncancerConc - NonCancer_HBV) <   NonCancer_HBV * .01)


# Find missing pollutants
xtra_rass <- filter(rass, !CAS %in% Risk_vals$CAS)
View(xtra_rass)

xtra_Access <- filter(Risk_vals, !CAS %in% rass$CAS)
View(xtra_Access)


#######