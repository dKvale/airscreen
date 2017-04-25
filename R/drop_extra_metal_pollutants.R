# Drop duplicate metals from benchmark tables
library(tidyverse)
library(readxl)
library(stringr)


# Load fair-screen pollutant names
fscreen <- read_csv("https://raw.githubusercontent.com/dKvale/fair-screen/master/data/air_benchmarks.csv")


# Identify duplicate pollutants
dups   <- filter(fscreen, grepl("Compound", Pollutant))

dups   <- filter(dups, !grepl("Cerium", Pollutant))

metals <- gsub(" Compounds", "", dups$Pollutant)

metals_df <- filter(fscreen, Pollutant %in% metals)


# Metals without duplicate rows
missing   <- metals[!metals %in% metals_df$Pollutant]

miss_df   <- filter(fscreen, grepl(missing[1], Pollutant) | grepl(missing[2], Pollutant))

miss_df   <- filter(miss_df, !grepl("Compound", Pollutant))


# Combine all duplicates
metals_df <- bind_rows(metals_df, miss_df)


# Replace specific metal rows with the generic "compounds" row
metals_df <- group_by(metals_df, row_number()) %>%
             mutate(Pollutant = substring(Pollutant)[[1]],
                    CAS = filter(dups, grepl(Pollutant, Pollutant))$CAS)


##