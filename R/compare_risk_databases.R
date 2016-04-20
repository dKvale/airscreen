library(RODBC)
library(dplyr)
library(stringr)

risk_connect <- odbcConnectAccess2007("X:\\Programs\\Air_Quality_Programs\\Air Monitoring Data and Risks\\4 Concentration to Risk Estimate Database\\Air Toxics Risks Estimates_update2015.accdb")

# Get data table or query in the database
Risk_vals <- sqlQuery(risk_connect, paste("select * from [Toxicity]"), stringsAsFactors=F)

odbcCloseAll()

# Clean white space & special characters
Risk_vals[ , 4] <- str_trim(gsub("\xca","", Risk_vals[ , 4]))
Risk_vals[ , 5] <- str_trim(gsub("\xca","", Risk_vals[ , 5]))


# Filter and clean
HBVs <- Risk_vals[ , c(4,5,8,16,21)]

names(HBVs)[1] <- "CAS"
names(HBVs)[2] <- "Pollutant"

##################

rass <- read.csv("C:/Users/dkvale/Desktop/RASS-risk.csv", stringsAsFactors=FALSE)

rass[ , 1] <- str_trim(gsub("\xca","", rass[ , 1]))
rass[ , 2] <- str_trim(gsub("\xca","", rass[ , 2]))

rass[ , 2] <- str_trim(gsub("ÿ","", rass[ , 2]))
rass[ , 1] <- str_trim(gsub("ÿ","", rass[ , 1]))


join <- left_join(rass[,-c(3,5,7)], HBVs)

names(join) <- c("CAS","Pollutant", "AcuteConc","CancerConc","NoncancerConc",
                  "Acute_HBV","Cancer_HBV", "NonCancer_HBV" ) 

join <- join[,c(1,2,3,6,4,7,5,8)]

# Find tox value differences
join <- mutate(join, 
               acute_test     = abs(AcuteConc - Acute_HBV) <   Acute_HBV * .01,
               cancer_test    = abs(CancerConc - Cancer_HBV) <   Cancer_HBV * .01,
               nonCancer_test = abs(NoncancerConc - NonCancer_HBV) <   NonCancer_HBV * .01)


# Find missing pollutants
xtra_rass <- filter(rass, !CAS %in% Risk_vals$CAS)
View(xtra_rass)

xtra_Access <- filter(Risk_vals, !CAS %in% rass$CAS)
View(xtra_Access)


#######