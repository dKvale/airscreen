library(RODBC)
library(dplyr)
library(readr)
library(stringr)
library(readxl)

risk_connect <- odbcConnectAccess2007("X:\\Programs\\Air_Quality_Programs\\Air Monitoring Data and Risks\\4 Concentration to Risk Estimate Database\\Air Toxics Risks Estimates_update2015.accdb")

# Get data table or query in the database
risk_vals <- sqlQuery(risk_connect, paste("select * from [Toxicity]"), stringsAsFactors=F)

rm(risk_connect)

odbcCloseAll()

# Filter and clean
risk_vals <- risk_vals[ , c(4,5,8,16,21)]

names(risk_vals)[1] <- "CAS"
names(risk_vals)[2] <- "Pollutant_acc"

risk_vals$CAS <- str_trim(risk_vals$CAS)



##################

rass <- read_excel("X:/Agency_Files/Outcomes/Risk_Eval_Air_Mod/_Air_Risk_Evaluation/AERA program/RASS/AERA RASS (aq9-22-7) - April 2017.xlsx", 7, skip = 18)

rass <- rass[ , -c(1,2)]

names(rass)[c(1,25)] <- c("CAS","Subchronic Ref Conc")

rass$CAS <- str_trim(rass$CAS)

risks <- left_join(rass[ , -c(3,4,6:12,14:17,19:24,26:32)], risk_vals)

#rm(rass)
#rm(risk_vals)

names(risks) <- c("CAS","Pollutant", 
                  "AcuteConc","CancerConc",
                  "NoncancerConc", "SubchronConc",
                  "Pollutant_acc", "Acute_acc",
                  "Cancer_acc","Noncancer_acc") 

risks <- filter(risks, !is.na(CAS))


#risks <- risks[ ,c(1,2,3,6,4,7,5,8)]

# Find tox value differences
rass_comp <- mutate(risks, 
                    acute_test     = abs(AcuteConc - Acute_acc) <   Acute_acc * .01,
                    cancer_test    = abs(CancerConc - Cancer_acc) <   Cancer_acc * .01,
                    nonCancer_test = abs(NoncancerConc - Noncancer_acc) <   Noncancer_acc * .01)


# Fair-screen compare
fscreen <- read_csv("https://raw.githubusercontent.com/dKvale/fair-screen/master/data/air_benchmarks.csv")


# Join risk references to fair-screen pollutants
#fscreen <- left_join(fscreen, risk_vals)

rass    <- rass[ , -c(3,4,6:12,14:17,19:24,26:32)]

fscreen <- left_join(fscreen, rass)

names(fscreen) <- c("CAS","Pollutant", 
                    "AcuteConc","SubchronConc",
                    "NoncancerConc", "CancerConc",
                    "Pollutant_acc", "Acute_acc",
                    "Cancer_acc","Noncancer_acc",
                    "Subchronic_acc") 


# Find tox value differences
fscreen_comp <- mutate(fscreen, 
                       acute_test     = abs(AcuteConc - signif(Acute_acc, 3)) <   Acute_acc * .01,
                       subchron_test  = abs(SubchronConc - signif(Subchronic_acc, 3)) <   Subchronic_acc * .01,
                       cancer_test    = abs(CancerConc - signif(Cancer_acc, 2)) <   Cancer_acc * .01,
                       nonCancer_test = abs(NoncancerConc - signif(Noncancer_acc,2)) <   Noncancer_acc * .01)



# Save
#write_csv(rass_comp, "risk_compare.csv")

# Find missing pollutants
xtra_rass <- filter(risks, !CAS %in% risk_vals$CAS)
View(xtra_rass)

xtra_Access <- filter(risk_vals, !CAS %in% risks$CAS)
View(xtra_Access)


#######