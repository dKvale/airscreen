
version <- "2016.05.01"

cancer_guideline <- 1e-05

helper_text <-  "* Select an Excel file (.xlsx) or comma separated text file (.csv)"

file_types <- c('.xlsx', '.xls', '.csv', 'text/.csv', 'text/csv')

tox_values <- read.csv("data//air_benchmarks.csv", header=T, stringsAsFactors=F, nrows=400, check.names=F)
endpoints <- read.csv("data//air_endpoints.csv", header=T, stringsAsFactors=F, nrows=400, check.names=F)

endpoints_list <- c('Auditory', 'Blood/ hematological', 'Bone & teeth', 'Cardiovascular', 'Digestive', 'Ethanol specific', 'Eyes', 'Kidney', 'Liver', 'Neurological', 'Reproductive/ developmental/ endocrine', 'Respiratory', 'Skin')
endpoints_list <- data.frame("Endpoint" = endpoints_list, stringsAsFactors = F)
endpoints_list$End_short <- substring(endpoints_list$Endpoint, 1, 4)

disp_facts <- read.csv("data//dispersion_factors.csv", header=T, stringsAsFactors=F, nrows=400, check.names=F)

mpsf <- read.csv("data//MPSFs.csv", header=T, stringsAsFactors=F, nrows=400, check.names=F)

risk_table_names <- c("Pollutant", "CAS", "Acute 1-hr Hazard Quotient (Air)", "Longterm Hazard Quotient (Air)", "Longterm Cancer Risk (Air)", "Resident Longterm Hazard Quotient (All media)", "Resdident Longterm Cancer Risk (All media)", "Urban Gardener Longterm Hazard Quotient (All media)", "Urban Gardener Longterm Cancer Risk (All media)","Farmer Hazard Quotient (All media)", "Farmer Longterm Cancer Risk (All media)")

# Create table for coordinates
coords <- read.csv(textConnection("lat,long
                                   46.29015, -96.063"))

facility <- "Example Facility 44"
#address <- "431 Broom ST W., Murphy Town MN 55290"

in.file <- function(conn, tab=1, n_col, col_names) {
  
  if(grepl(".xls", conn$name)) {
    
    file.rename(conn$datapath, paste0(conn$datapath, ".xlsx"))
    
    in_file <- read_excel(paste0(conn$datapath, ".xlsx"), tab)[ , 1:n_col]
    
  } else {
    
    in_file <- read.csv(conn$datapath, stringsAsFactors=F)[ , 1:n_col]
  }
  
  in_file <- data.frame(in_file, stringsAsFactors = F, check.names=F)
  
  names(in_file) <- col_names
  
  return(in_file)
}

write_sheet <- function(wb, sheet, df) {
  createSheet(wb, name = sheet)
  writeWorksheet(wb, df, sheet)
}

# Example tables
ex_emissions <- data.frame("Stack ID" = rep(c('Stack-1', 'Stack-2'), each = 4),
             "Pollutant" = rep(c("Acrolein","Benzene", "Lead", "Diisopropyl Ether"), 2), 
             "CAS" = rep(c("107-02-8","71-43-2", "7439-92-1", "108-20-3"), 2), 
             "1-hr PTE Emissions (lbs/hr)" = c(0.3, 0.02, 0.1, 0.5, 0.4, 0.03, 0.1, 0.5),
             "Annual PTE Emissions (tons/yr)" = c(1, 0.15, 0.01, 2, 1, 0.4, 0.01, 2),
             check.names=F, stringsAsFactors=F)

ex_disperion <- data.frame("Stack ID" = c("Stack-1","Stack-2"), 
                           "1-Hour Max" = c(1, 2), 
                           "Annual Max" = c(.06, .15), 
                           check.names=F, stringsAsFactors=F)

ex_stacks <- data.frame("Stack ID" = c("Stack-1","Stack-2"), 
                        "Stack Height" = c(80, 99), 
                        "Distance to Fenceline" = c(55, 38), 
                        check.names = F, stringsAsFactors = F)

##