# Check CAS#s match between tables
library(tidyverse)
library(readxl)
library(stringr)


# Load pollutant tables
risks  <- read_csv("https://raw.githubusercontent.com/dKvale/fair-screen/master/data/air_benchmarks.csv")

endpt  <- read_csv("https://raw.githubusercontent.com/dKvale/fair-screen/master/data/air_endpoints.csv")

refs   <- read_csv("https://raw.githubusercontent.com/dKvale/fair-screen/master/data/air_benchmark_references.csv")

groups <- read_csv("https://raw.githubusercontent.com/dKvale/fair-screen/master/data/air_groups.csv")

mpsf   <- read_csv("https://raw.githubusercontent.com/dKvale/fair-screen/master/data/mutli_pathway_risk_factors.csv")

ethanol <- read_csv("https://raw.githubusercontent.com/dKvale/fair-screen/master/data/ethanol_pollutants.csv")

closeAllConnections()

# Create unique column name
names(endpt)[2]   <- "Pollutant_endpt"
names(refs)[2]    <- "Pollutant_refs"
names(groups)[2]  <- "Pollutant_groups"
names(mpsf)[2]    <- "Pollutant_mpsf"


# CAS updates
change_date <- NA #"2017-04-25"

if(change_date == "2017-04-25") {
  
  # Endpoints
  endpt[endpt$Pollutant_endpt == "Benzo(k)fluoranthene", ]$CAS <- risks[risks$Pollutant == "Benzo(k)fluoranthene", ]$CAS
  endpt[endpt$Pollutant_endpt == "Formic Acid", ]$CAS <- risks[risks$Pollutant == "Formic Acid", ]$CAS
  endpt[endpt$Pollutant_endpt == "Furfural", ]$CAS <- risks[risks$Pollutant == "Furfural", ]$CAS
  
  # Add carbonyl sulfide
  endpt <- bind_rows(endpt, data_frame(Pollutant_endpt = "Carbonyl sulfide"))
  
  endpt[endpt$Pollutant_endpt == "Carbonyl sulfide", ]$CAS  <- risks[risks$Pollutant == "Carbonyl sulfide", ]$CAS
  endpt[endpt$Pollutant_endpt == "Carbonyl sulfide", ]$`Chronic Noncancer Endpoints`  <- "Systemic, Neuro"
  endpt[endpt$Pollutant_endpt == "Carbonyl sulfide", ]$`Subchronic Toxic Endpoints`   <- "Neuro"
  
  # Add Nitroaniline, 2-
  endpt <- bind_rows(endpt, data_frame(Pollutant_endpt = "Nitroaniline, 2-"))
  
  endpt[endpt$Pollutant_endpt == "Nitroaniline, 2-", ]$CAS  <- risks[risks$Pollutant == "Nitroaniline, 2-", ]$CAS
  endpt[endpt$Pollutant_endpt == "Nitroaniline, 2-", ]$`Subchronic Toxic Endpoints`   <- "Eyes, Resp"
  
  # Chloronitrobenzene, o-
  endpt <- bind_rows(endpt, data_frame(Pollutant_endpt = "Chloronitrobenzene, o-"))
  
  endpt[endpt$Pollutant_endpt == "Chloronitrobenzene, o-", ]$CAS  <- risks[risks$Pollutant == "Chloronitrobenzene, o-", ]$CAS
  endpt[endpt$Pollutant_endpt == "Chloronitrobenzene, o-", ]$`Subchronic Toxic Endpoints`   <- "Resp"
  
  
  # Groups
  groups[groups$Pollutant_groups == "Benzo(k)fluoranthene", ]$CAS <- risks[risks$Pollutant == "Benzo(k)fluoranthene", ]$CAS
  groups[groups$Pollutant_groups == "Formic Acid", ]$CAS          <- risks[risks$Pollutant == "Formic Acid", ]$CAS

  # Add Furfural
  groups <- bind_rows(groups, data_frame(Pollutant_groups = "Furfural", CAS = "98-01-1"))
  
  
  # MPSFs
  mpsf[mpsf$Pollutant_mpsf == "Benzo(k)fluoranthene", ]$CAS <- risks[risks$Pollutant == "Benzo(k)fluoranthene", ]$CAS
  mpsf[mpsf$Pollutant_mpsf == "Formic Acid", ]$CAS          <- risks[risks$Pollutant == "Formic Acid", ]$CAS
  mpsf[mpsf$Pollutant_mpsf == "Fluorides (except hydrogen fluoride)", ]$CAS <- 
     risks[risks$Pollutant == "Fluorides (except hydrogen fluoride)", ]$CAS
  
  # Add Furfural
  mpsf <- bind_rows(mpsf, data_frame(CAS = "98-01-1", Pollutant_mpsf = "Furfural"))
  
  # Add Nitrogen oxides
  mpsf <- bind_rows(mpsf, data_frame(CAS = "VARIOUS-NOx", Pollutant_mpsf = "Nitrogen oxides (NOx)"))
  
  
}


# Join all tables
all_tables <- left_join(risks[ , 1:2], endpt[ , 1:2])
all_tables <- left_join(all_tables, refs[ , 1:2])
all_tables <- left_join(all_tables, groups[ , 1:2])
all_tables <- left_join(all_tables, mpsf[ , 1:2])


# Check for missing CAS#'s
miss_endpt <- filter(all_tables, is.na(Pollutant_endpt))
print(nrow(miss_endpt))

miss_refs <- filter(all_tables, is.na(Pollutant_refs))
print(nrow(miss_refs))

miss_groups <- filter(all_tables, is.na(Pollutant_groups), !CAS %in% ethanol$CAS)
print(nrow(miss_groups))

miss_mpsf <- filter(all_tables, is.na(Pollutant_mpsf), !CAS %in% ethanol$CAS)
print(nrow(miss_mpsf))


# Save tables
#write_csv(risks, "data/air_benchmarks.csv")
write_csv(endpt, "data/air_endpoints.csv")
write_csv(groups, "data/air_groups.csv")
write_csv(mpsf, "data/multi_pathway_risk_factors.csv")


##
