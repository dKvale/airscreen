# 
# This is the server logic for the MPCA's air risk screening tool.
# 
# You can find out more about air pollution and risk assessment at
#           http://www.pca.state.mn.us/mvrifb5
#
# March 27th, 2015
library(shiny)
library(dplyr)
library(leaflet)
library(DT)
library(readxl)
library(XLConnect)

version <- "4/14/2016"

cancer_guideline <- 1e-05

tox_values <- read.csv("data//air_benchmarks.csv", header=T, stringsAsFactors=F, nrows=400, check.names=F)
endpoints <- read.csv("data//air_endpoints.csv", header=T, stringsAsFactors=F, nrows=400, check.names=F)

endpoints_list <- c('Auditory', 'Blood/ hematological', 'Bone & teeth', 'Cardiovascular', 'Digestive', 'Ethanol specific', 'Eyes', 'Kidney', 'Liver', 'Neurological', 'Reproductive/ developmental / endocrine', 'Respiratory', 'Skin')
endpoints_list <- data.frame("Endpoint" = endpoints_list)
endpoints_list$End_short <- substring(endpoints_list$Endpoint, 1, 4)

disp_facts <- read.csv("data//dispersion_factors.csv", header=T, stringsAsFactors=F, nrows=400, check.names=F)

mpsf <- read.csv("data//MPSFs.csv", header=T, stringsAsFactors=F, nrows=400, check.names=F)

risk_table_names <- c("Pollutant", "CAS", "Acute 1-hr Hazard Quotient (Air)", "Longterm Hazard Quotient (Air)", "Longterm Cancer Risk (Air)", "Resident Longterm Hazard Quotient (All media)", "Resdident Longterm Cancer Risk (All media)", "Urban Gardener Longterm Hazard Quotient (All media)", "Urban Gardener Longterm Cancer Risk (All media)","Farmer Hazard Quotient (All media)", "Farmer Longterm Cancer Risk (All media)")

# Create table for coordinates
coords <- read.csv(textConnection("
lat,long
46.29015, -96.063"))


address <- "431 Broom St. North, Murphy Town"

in.file <- function(conn, tab=1, n_col, col_names) {
  
  if(grepl(".xls", conn$name)) {
  
    file.rename(conn$datapath, paste0(conn$datapath, ".xlsx"))
  
    in_file <- read_excel(paste0(conn$datapath, ".xlsx"), tab)[ , 1:n_col]
  
  } else {
    
    in_file <- read.csv(conn$datapath, stringsAsFactors=F)[ , 1:n_col]
  }
  
  names(in_file) <- col_names
  
  return(in_file)
 }


shinyServer(function(input, output, session) {
  
  #################################
  # Facility Map
  ################################
  fac.info <- reactive({
    
    if(is.null(input$inputs_up)) return(NULL)
    
    col_names <- c("Facility Name",	"Facility ID#",	"Facility Address",	"Latitude",	"Longitude")
    
    return(in.file(input$inputs_up, 2, 5, col_names))
      
  })
 
  output$fac_name_UI <- renderUI({
    textInput('fac_name', label=NULL, placeholder="Example Facility (#123456)", value="Example Facility (#123456)")
  })
  
  output$address_UI <- renderUI({
    textInput('address', label=NULL, placeholder='431 Broom St. North, Murphy Town')
  })
  
  output$fac_lat_UI <- renderUI({
    textInput('lat', label=NULL, placeholder='46.29', value = '46.29')
  })
  
  output$fac_long_UI <- renderUI({
    textInput('long', label=NULL, placeholder='-96.063', value='-96.063')
  })
  
  observeEvent(input$inputs_up, {
    updateTextInput(session, 'fac_name', value= as.character(fac.info()[1, 1])[[1]])
    updateTextInput(session, 'address', value=fac.info()[1, 3][[1]])
    updateTextInput(session, 'lat', value=fac.info()[1, 4][[1]])
    updateTextInput(session, 'long', value=fac.info()[1, 5][[1]])
  })
  
  output$fac_map <- renderLeaflet({
   
    if(is.null(input$fac_name)) return(leaflet())
    
    coords[1, 1] <- as.numeric(input$lat)
    coords[1, 2] <- as.numeric(input$long)
    
    print("New:")
    #print(facility)
    print(coords[1, 1])
    print(coords[1, 2])
    
    leaflet() %>% 
    addTiles() %>% 
    addMarkers(data=coords, popup=input$fac_name) %>%
      addCircles(data=coords, weight = 1, fillColor= "orange", color="darkorange",
                 radius = 1500, popup = "1.5km impact radius") %>%
      addCircles(data=coords, weight = 1,
                 radius = min(stack.table()$"Distance to Fenceline", na.rm=T), popup = "Estimated property boundary")
    })
  
  #################################
  # Stacks
  ################################
  
  stack.table <- reactive({
    
    col_names <- c("Stack ID", "Stack Height", "Distance to Fenceline")
    
    if(!is.null(input$stack_up)) { return(in.file(input$stack_up, 1, 3, col_names)) }
      
    if(!is.null(input$inputs_up)) { return(in.file(input$inputs_up, 3, 3, col_names)) }
    
    data.frame("Stack ID" = c("Stack-1","Stack-2"), 
               "Stack Height" = c(80, 99), 
               "Distance to Fenceline" = c(55, 38), 
               check.names = F, stringsAsFactors = F)
    
  })
  
  output$stack_table <- DT::renderDataTable(stack.table(), options=list(searching=F, paging=F, scrollX=T), rownames = FALSE)
  
  ######################
  # Dispersion factors
  ######################

  disp.table <- reactive({
    
    col_names <- c("Stack ID", "1-Hour Max", "Annual Max")
    
    if(!is.null(input$disp_up)) { return(in.file(input$disp_up, tab=1, n_col=3, col_names)) } 
      
    if(!is.null(input$inputs_up)) { return(in.file(input$inputs_up, tab=4, n_col=3, col_names)) }
      
    if(!is.null(stack.table())) { 
      
      stacks <- stack.table()
      
      n_stacks <- nrow(stacks)
      
      disp_table <- data.frame("Stack ID" = stacks[ , 1], 
                               "1-Hour Max"  = 1:n_stacks, 
                               "Annual Max"  = 1:n_stacks, 
                               check.names=F, stringsAsFactors=F)
      
      if(input$st_units == "Feet") stacks$'Stack Height' <- stacks$'Stack Height' * 0.3048
      
      for(stack in 1:n_stacks) {
        nearD <- min(as.numeric(gsub("X","", names(disp_facts)[3:32]))[as.numeric(gsub("X", "", names(disp_facts)[3:32])) >= floor(stacks[stack, 3]/10)*10])
        if(stacks[stack, 3]>=10000) nearD <- 10000
        nearH <- min(round(stacks[stack, 2], 0), 99)
        disp_table[stack, 2:4] <- c(disp_facts[disp_facts$"Averaging.Time"=="1-hr" & disp_facts$"Stack.Height.meters" == nearH, paste0("X", nearD)],
                                    disp_facts[disp_facts$"Averaging.Time"=="annual" & disp_facts$"Stack.Height.meters" == nearH, paste0("X", nearD)])
      }
    } else { 
      disp_table <- 
        data.frame("Stack ID" = c("Stack-1","Stack-2"), 
                   "1-Hour Max" = c(1, 2), 
                   "Annual Max" = c(.06, .15), 
                   check.names=F, stringsAsFactors=F)
    }
      
    return(disp_table[ , 1:3])
  })
  
  output$disp_table <- DT::renderDataTable(disp.table(), options=list(searching=F, paging=F, scrollX=T), rownames = FALSE)

  #################################
  # Emissions
  ################################

  em.table <- reactive({
    
    col_names <- c("Stack ID", "Pollutant", "CAS", "1-hr PTE Emissions (lbs/hr)", "Annual PTE Emissions (tons/yr)")
    
    if(!is.null(input$emissions_up)) { return(in.file(input$emissions_up, tab=1, n_col=5, col_names)) }
      
    if(!is.null(input$inputs_up)) { return(in.file(input$inputs_up, tab=5, n_col=5, col_names)) }
    
    data.frame("Stack ID" = rep(c('Stack-1', 'Stack-2'), each = 4),
               "Pollutant" = rep(c("Acrolein","Benzene", "Lead", "Diisopropyl Ether"), 2), 
               "CAS" = rep(c("107-02-8","71-43-2", "7439-92-1", "108-20-3"), 2), 
               "1-hr PTE Emissions (lbs/hr)" = c(0.3, 0.02, 0.1, 0.5, 0.4, 0.03, 0.1, 0.5),
               "Annual PTE Emissions (tons/yr)" = c(1, 0.15, 0.01, 2, 1, 0.4, 0.01, 2),
               check.names=F, stringsAsFactors=F)
  })
  
  output$emissions_table <- DT::renderDataTable(em.table(), options=list(searching=F, paging=F, scrollX=F), rownames = FALSE)
  
  #######################
  # Concentration tables
  #######################
  
  st.conc.table <- reactive({
    
    st.conc.table <- left_join(em.table(), disp.table())
    
    names(st.conc.table) <- c("Stack", "Pollutant", "CAS", "hr_PTE", "an_PTE", "hr_disp", "an_disp")
    
    st.conc.table <- group_by(st.conc.table, Stack, Pollutant, CAS) %>%
                     summarize(hr_max = signif(hr_PTE * hr_disp * 453.592 / 3600, 4),
                               annual_max = signif(an_PTE * an_disp * 2000 * 453.592 / 8760 / 3600, 4))
    
    names(st.conc.table) <- c("Stack ID", "Pollutant", "CAS", "1-hr Max", "Annual Max")
  
    st.conc.table
    })
  
  output$st_conc_table <- DT::renderDataTable(st.conc.table(), options=list(searching=F, paging=F, scrollX=T,  digits=1), rownames = FALSE)
  
  conc.table <- reactive({
    
    col_names <- c("Pollutant", "CAS", "1-hr Max", "Annual Max")
    
    if(!is.null(input$conc_up)) { return(in.file(input$conc_up, tab=1, n_col=4, col_names)) } 
    
    if(!is.null(input$inputs_up)) { 
      conc_table <- in.file(input$inputs_up, tab=6, n_col=4, col_names)
      
      if(nrow(conc_table) >= length(unique(em.table()$Pollutant))) return(conc_table)
       }
    
    conc.table <- st.conc.table()
    
    names(conc.table) <- c("Stack", "Pollutant", "CAS", "hr", "an")
    
    group_by(conc.table, Pollutant, CAS) %>%
        summarize("1-hr Max" = sum(hr, na.rm=T),
                  "Annual Max" = sum(an, na.rm=T))
  })
  
  output$conc_table <- DT::renderDataTable(conc.table(), options=list(searching=F, paging=F, scrollX=T, digits=2), rownames = FALSE)
   
  ####################
  # Risk tables
  ####################
  risk.table <- reactive({
    if(!is.null(conc.table())){   
      
      risk_table <- data.frame(left_join(ungroup(conc.table()), tox_values),
                               check.names=F, stringsAsFactors = F)
      
      risk_table <- left_join(risk_table, mpsf[ ,-2])
  
      risk_table$"Acute (Air)"            <- risk_table[ ,3]/risk_table[ ,5]
      risk_table$"Longterm Hazard (Air)"  <- risk_table[ ,4]/risk_table[ ,7]
      risk_table$"Longterm Cancer (Air)"  <- risk_table[ ,4]/risk_table[ ,8] * cancer_guideline
      
      risk_table <- risk_table[ , c(1:2,15:17,9:14)]
      
      # Multi-media
      risk_table$"Resident Hazard (All media)"  <- risk_table[ ,4] * (1 + risk_table[ ,6])
      risk_table$"Resdident Cancer (All media)" <- risk_table[ ,5] * (1 + risk_table[ ,7]) 
      risk_table$"Gardener Hazard (All media)"  <- risk_table[ ,4] * (1 + risk_table[ ,8])
      risk_table$"Gardener Cancer (All media)"  <- risk_table[ ,5] * (1 + risk_table[ ,9]) 
      risk_table$"Farmer Hazard (All media)"    <- risk_table[ ,4] * (1 + risk_table[ ,10])
      risk_table$"Farmer Cancer (All media)"    <- risk_table[ ,5] * (1 + risk_table[ ,11]) 
      
      risk_table <- risk_table[ , -c(6:11)]
      
    } else {
      risk_table <- data.frame(matrix(NA, nrow=1, ncol=12), check.names=F, stringsAsFactors = F)
    }
    
    names(risk_table) <- risk_table_names
    
    return(risk_table)
  })
  
  # Pollutant risk table
  pollutant.risk.table <- reactive({
    pol_risk <- risk.table()
    
    for(i in c(3:4,6,8,10)) {
      pol_risk[ ,i] <- round(pol_risk[ ,i], digits=3)
      pol_risk[is.na(pol_risk[ ,i]), i] <- ""
      pol_risk[grepl("NA", pol_risk[ ,i]), i] <- ""
    }
    
    for(i in c(5,7,9,11)) {
      pol_risk[ ,i] <- format(signif(pol_risk[ ,i], digits=2), scientific=T)
      pol_risk[is.na(pol_risk[ ,i]), i] <- ""
      pol_risk[grepl("NA", pol_risk[ ,i]), i] <- ""
    }
    
    pol_risk
    
  })
  
  output$pollutant_risk_table <- DT::renderDataTable(pollutant.risk.table()[ ,], options=list(searching=F, paging=F, scrollX=F), rownames = FALSE)
  #output$media_risk_table <- DT::renderDataTable(pollutant.risk.table()[ ,c(1:2,7:12)], options=list(searching=F, paging=F, scrollX=F), rownames = FALSE)
  
  # Total risk table
  total.risk.table <- reactive({
    
    if(!is.null(risk.table())) {  
      
      total_risk <- risk.table()
      
      total_risk <- data.frame(
        "Acute  (Air)"                 = sum(total_risk[ ,3], na.rm=T), 
        "Longterm Hazard (Air)"        = sum(total_risk[ ,4], na.rm=T), 
        "Longterm Cancer (Air)"        = sum(total_risk[ ,5], na.rm=T), 
        "Resident Hazard (All media)"  = sum(total_risk[ ,6], na.rm=T),
        "Resdident Cancer (All media)" = sum(total_risk[ ,7], na.rm=T),
        "Gardener Hazard (All media)"  = sum(total_risk[ ,8], na.rm=T),
        "Gardener Cancer (All media)"  = sum(total_risk[ ,9], na.rm=T),
        "Farmer Hazard (All media)"    = sum(total_risk[ ,10], na.rm=T), 
        "Farmer Cancer (All media)"    = sum(total_risk[ ,11], na.rm=T), 
        check.names=F)  
      
      for(i in c(1,2,4,6,8)) {total_risk[ ,i] <- round(total_risk[ ,i], digits=2)}
      
      for(i in c(3,5,7,9)) {total_risk[ ,i] <- format(signif(total_risk[ ,i], digits=2), scientific=T)}
      
    } else {
      total_risk <- data.frame(matrix(NA, nrow=1, ncol=10), check.names=F, stringsAsFactors = F)
    }
    
    names(total_risk) <- risk_table_names[-c(1,2)]
    
    return(total_risk)
    })

  output$total_air_risk_table <- DT::renderDataTable(total.risk.table()[ ,1:4], options=list(searching=F, paging=F, scrollX=F, digits=2), rownames = FALSE)
  output$total_media_risk_table <- DT::renderDataTable(total.risk.table()[ ,5:10], options=list(searching=F, paging=F, scrollX=F, digits=2), rownames = FALSE)
  
  # Endpoint risk table
  endpoint.risk.table <- reactive({
    
    endpoint_risks <- data.frame(left_join(risk.table()[ ,1:4], endpoints), stringsAsFactors = F, check.names=F)
    
    if(!is.null(endpoint_risks) && nrow(endpoint_risks) > 0) {   
      end_risks <- endpoints_list
      
      for(i in 1:nrow(end_risks)) {
        end_risks$"Acute 1-hr Hazard Quotient (Air)"[i] <- sum(filter(endpoint_risks, grepl(end_risks$End_short[i], Acute_Toxic_Endpoints) | Acute_Toxic_Endpoints == "Systemic")$"Acute 1-hr Hazard Quotient (Air)", na.rm=T) 
        end_risks$"Longterm Hazard Quotient (Air)"[i]   <- sum(filter(endpoint_risks, grepl(end_risks$End_short[i], Chronic_Noncancer_Endpoints) | Chronic_Noncancer_Endpoints == "Systemic")$"Longterm Hazard Quotient (Air)", na.rm=T) 
      }
      
      end_risks[ ,2] <- NULL
      
      # Round acute risk
      end_risks[ ,2] <- round(end_risks[ ,2], digits = 2)
      end_risks[ ,2] <- ifelse(as.numeric(end_risks[ ,2]) < 0.0001, NA, end_risks[ ,2])
      
      # Set cancer digits
      end_risks[ ,3] <- format(signif(end_risks[ ,3], digits=2), scientific=T)
      end_risks[ ,3] <- ifelse(as.numeric(end_risks[ ,3]) < 0.0001, NA, end_risks[ ,3])
      
    } else {end_risks  <- data.frame("Acute 1-hr Hazard Quotient (Air)", "Subchronic Hazard Quotient (Air)", "Longterm Hazard Quotient (Air)", check.names=F)}
    
    return(end_risks)
  })
  
  output$endpoint_risk_table <- DT::renderDataTable(endpoint.risk.table(), options=list(searching=F, paging=F, scrollX=F), rownames = FALSE)
 
  # Pollutants of concern
  pbts <- reactive({
    pbt_table <- left_join(em.table(), endpoints[ ,-c(3:5)])
    
    pbt_table <- filter(pbt_table, Persistent_Bioaccumulative_Toxicants > 0)[ , 2:3]
    
    #names(pbt_table)[1] <- "PBT Pollutants"
    unique(pbt_table)
    
  })
  
  output$pbt_table <- DT::renderDataTable(pbts(), options=list(searching=F, paging=F, scrollX=F), rownames = FALSE)
  
  # Developmental
  develop.tox <- reactive({
    develop_tox <- left_join(em.table(), endpoints[ ,-c(3:5)])
    
    develop_tox <- filter(develop_tox, Developmental_Toxicants > 0)[ , 2:3]
    
    #names(develop_tox)[1] <- "Developmental Pollutant"
    unique(develop_tox)

  })
  
  output$develop_table <- DT::renderDataTable(develop.tox(), options=list(searching=F, paging=F, scrollX=F), rownames = FALSE)
  
  # Sensitizers
  sensitive.tox <- reactive({
    sensitive_tox <- left_join(em.table(), endpoints[ ,-c(3:5)])
    
    sensitive_tox <- filter(sensitive_tox, Respiratory_Sensitizers > 0)[ , 2:3]
    
    #names(sensitive_tox)[1] <- "Respiratory sensitizing pollutants"
    unique(sensitive_tox)
  })
  
  output$sensitive_table <- DT::renderDataTable(sensitive.tox(), options=list(searching=F, paging=F, scrollX=F), rownames = FALSE)
   
  ########################
  # SAVE
  ########################
  
  #Download Buttons
  output$download_inputs <- downloadHandler(
        filename = function() { paste0("RASS_Inputs_", Sys.Date(), ".xlsx", sep="") },
        content = function(file) {
         # fname <- paste(file,"xlsx",sep=".")
          wb <- loadWorkbook(file, create = TRUE)
          createSheet(wb, name = "Sheet1")
          writeWorksheet(wb, c(1:3), sheet = "Sheet1") 
          
          createSheet(wb, name = "Sheet2")
          writeWorksheet(wb, c(1:13), sheet = "Sheet2") 
          
          saveWorkbook(wb, file)
          #file.rename(fname,file)
   })
  
  
  ########################
  # MORE
  #######################
  output$tox_table <- DT::renderDataTable(tox_values, options=list(searching=F, paging=F, scrollX=T), rownames = FALSE)
  
  output$endpoints <- DT::renderDataTable(endpoints, options=list(searching=F, paging=F, scrollX=T), rownames = FALSE)
  
  output$mpsf      <- DT::renderDataTable(mpsf, options=list(searching=F, paging=F, scrollX=T), rownames = FALSE)
  
})
