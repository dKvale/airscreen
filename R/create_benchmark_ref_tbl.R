# Create air benchmark references table
library(tidyverse)
library(readxl)
library(stringr)

# Load MPCA's RASS table
rass    <- read_excel("X:/Agency_Files/Outcomes/Risk_Eval_Air_Mod/_Air_Risk_Evaluation/AERA program/RASS/AERA RASS (aq9-22-7) - April 2017.xlsx", 7, skip = 18)

rass    <- rass[ , -c(1:2,5,8:10,12,14,16:18,21:25,28:34)]

names(rass) <- c("CAS",
                 "Pollutant_rass",
                 "Acute ref",
                 "Acute Reference Conc",
                 "Surrogate CAS",
                 "Cancer ref",
                 "Cancer benchmark",
                 "Chronic non_cancer ref", 
                 "Chronic non_cancer conc",
                 "Subchronic ref",
                 "Subchronic conc")


rass$CAS <- str_trim(rass$CAS)

# Remove duplicate ethanol rows
ethanol <- c("Acetic Acid",
             "Formic Acid",
             "Lactic Acid",
             "Propionic Acid",
             "Butanol",
             "Ethanol",
             "Isoamyl",
             "Propanol",
             "Butyraldehyde",
             "Furfural",
             "Proprionaldehyde",
             "Benzaldehyde",
             "Ethyl Acetate")

rass    <- filter(rass, !Pollutant_rass %in% ethanol)

# Drop extra chromium
rass    <- filter(rass, !Pollutant_rass %in% "Chromium (Hexavalent) (particulate)")

# Load fair-screen pollutant names
fscreen <- read_csv("https://raw.githubusercontent.com/dKvale/fair-screen/master/data/air_benchmarks.csv")


# Join risk references to fair-screen pollutants
fscreen <- left_join(fscreen, rass)

# Reorder
fscreen <- fscreen[ , c(1:2,7,3,8,4,15,5,13,6,11)]


# Update missing values
missing <- filter(fscreen, is.na(Pollutant_rass))

fscreen[fscreen$Pollutant == "Nitrogen oxides (NOx)", ]$`Acute ref` <- fscreen[fscreen$Pollutant %in% "Nitrogen dioxide (NO2)", ]$`Acute ref`

fscreen[fscreen$Pollutant %in% "Chromic acid mists and dissolved Cr(VI) aerosols", c(3,7,9,11)] <- fscreen[fscreen$Pollutant_rass %in% "Chromic acid mists and dissolved Cr(VI) aerosols", c(3,7,9,11)]


# Update ethanol specific references
eth_df <- filter(fscreen, Pollutant_rass %in% ethanol | Pollutant %in% ethanol)

fscreen[fscreen$Pollutant %in% ethanol, c(5,9)] <- "MDH ethanol specific"

fscreen[fscreen$Pollutant == "Ethyl Acetate", ]$`Subchronic ref` <- "PPRTV"

fscreen[fscreen$Pollutant == "Ethyl Acetate", ]$`Chronic Non-cancer Reference Conc (ug/m3)` <- 70

fscreen[fscreen$Pollutant == "Formic Acid", 7] <- "PPRTV"

fscreen[fscreen$Pollutant == "Formic Acid", 9] <- NA


# Check for missing benchmarks
miss_acute <- filter(fscreen, is.na(`Acute Reference Conc (ug/m3)`) & !is.na(`Acute ref`))

miss_sub   <- filter(fscreen, is.na(`Subchronic Non-cancer Reference Conc (ug/m3)`) & !is.na(`Subchronic ref`))

miss_haz   <- filter(fscreen, is.na(`Chronic Non-cancer Reference Conc (ug/m3)`) & !is.na(`Chronic non_cancer ref`))

miss_canc  <- filter(fscreen, is.na(`Chronic cancer risk of 1E-5 Air Conc (ug/m3)`) & !is.na(`Cancer ref`))


# Split off references 
refs   <- fscreen[ , c(1:2,5,7,9,11)]

names(refs)[3:6] <- c("Acute IHB Reference", "Subchronic Non-cancer IHB Reference", "Chronic Non-cancer IHB Reference","Cancer IHB Reference")


# Save
write_csv(refs, "data/air_benchmark_references.csv")

##