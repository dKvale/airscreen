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
#library(rCharts)

version <- "4/14/2016"

tox_values <- read.csv("data//air_benchmarks.csv", header=T, stringsAsFactors=F, nrows=500, check.names=F)

endpoints <- read.csv("data//air_endpoints.csv", header=T, stringsAsFactors=F, nrows=500, check.names=F)
names(endpoints) <- gsub(" ", "_", names(endpoints))

disp_facts <- read.csv("data//dispersion_factors.csv", header=T, stringsAsFactors=F, nrows=400, check.names=F)

mpsf <- read.csv("data//MPSFs.csv", header=T, stringsAsFactors=F, nrows=500, check.names=F)
names(mpsf)[1:2] <- c("CAS", "Pollutant")

#pol_list <- paste0(tox_values$Pollutant," (", tox_values[ ,"CAS"], ")")

# Create table for coordinates
coords <- read.csv(textConnection("
lat,long
46.29015, -96.063"))

facility <- "Murphy`s Vaccuum Cleaners"


inFile2 <- function(conn){
  
}


shinyServer(function(input, output, session) {
  
  #output$pollutants <- renderUI({selectizeInput("pollutant","", choices = pol_list, selected = "Acrolein (107-02-8)") })

  #################################
  # Facility Map
  ################################
  output$fac_map <- renderLeaflet({

    if(!is.null(input$lat) & nchar(input$lat) > 1) coords[1, 1] <- as.numeric(input$lat)
    if(!is.null(input$long) & nchar(input$long) > 1) coords[1, 2] <- as.numeric(input$long)
    
    if(!is.null(input$coords) & nchar(input$facility) > 1) facility <- input$facility
    
    print("New:")
    print(coords[1, 1])
    print(coords[1, 2])
    
    leaflet() %>% 
    addTiles() %>% 
    addMarkers(data=coords, popup=facility) %>%
      addCircles(data=coords, weight = 1, fillColor= "orange", color="darkorange",
                 radius = 2000, popup = "2km impact radius") %>%
      addCircles(data=coords, weight = 1,
                 radius = min(stack.table()$"Distance to Fenceline", na.rm=T), popup = "Estimated property boundary")
    })
  
  #################################
  # Stacks
  ################################
  
  stack.table <- reactive({
    
    if(!is.null(input$stack_up)){
      inFile <- input$stack_up
      
      file.rename(inFile$datapath, paste0(inFile$datapath, ".xlsx"))
      
      stack_up <- read_excel(paste0(inFile$datapath, ".xlsx"), 2)
      
      names(stack_up) <- c("Stack ID", "Stack Height", "Distance to Fenceline")
      
      stack_up
      
    } else {
    
    data.frame("Stack ID" = c("Stack-1","Stack-2"), 
               "Stack Height" = c(80, 99), 
               "Distance to Fenceline" = c(55, 38), 
               check.names = F, stringsAsFactors = F)
    }
  })
  
  output$stack_table <- DT::renderDataTable(stack.table(), options=list(searching=F, paging=F, scrollX=T), rownames = FALSE)
  
  ######################
  # Dispersion factors
  ######################
  output$disp_up <- renderUI({fileInput("disp_up", label=NULL) })
  
  disp.table <- reactive({
    if(!is.null(input$disp_up)) {
      d <- input$disp_up
      return(read.csv(d$datapath, stringsAsFactors=F))
    } else if(!is.null(stack.table())) { 
      
      stacks <- stack.table()
      
      n_stacks <- nrow(stacks)
      
      disp_table <- data.frame("Stack ID" = stacks[ , 1], 
                               "1-Hour Max"  = 1:n_stacks, 
                               "Monthly Max" = 1:n_stacks, 
                               "Annual Max"  = 1:n_stacks, 
                               check.names=F, stringsAsFactors=F)
      
      if(input$st_units == "Feet") stacks$'Stack Height' <- stacks$'Stack Height' * 0.3048
      
      for(stack in 1:n_stacks) {
        nearD <- min(as.numeric(gsub("X","", names(disp_facts)[3:32]))[as.numeric(gsub("X", "", names(disp_facts)[3:32])) >= floor(stacks[stack, 3]/10)*10])
        if(stacks[stack, 3]>=10000) nearD <- 10000
        nearH <- min(round(stacks[stack, 2], 0), 99)
        disp_table[stack, 2:4] <- c(disp_facts[disp_facts$"Averaging.Time"=="1-hr" & disp_facts$"Stack.Height.meters" == nearH, paste0("X", nearD)],
                                    disp_facts[disp_facts$"Averaging.Time"=="monthly" & disp_facts$"Stack.Height.meters" == nearH, paste0("X", nearD)],
                                    disp_facts[disp_facts$"Averaging.Time"=="annual" & disp_facts$"Stack.Height.meters" == nearH, paste0("X", nearD)])
      }
    } else { 
      data.frame("Stack ID" = c("Stack-1","Stack-2"), 
                 "1-Hour Max" = c(1, 2), 
                 "Montly Max" = c(.2, .34), 
                 "Annual Max" = c(.06, .15), 
                 check.names=F, stringsAsFactors=F)
    }
    return(disp_table[ ,1:4])
  })
  
  output$disp_table <- DT::renderDataTable(disp.table(), options=list(searching=F, paging=F, scrollX=T), rownames = FALSE)

  #################################
  # Emissions
  ################################
  output$emissions_up <- renderUI({fileInput("emissions_up", label=NULL) })
  
  em.table <- reactive({
    
    print(input$pollutant)
    
    if(!is.null(input$emissions_up)) {
      b <- input$emissions_up
      return(read.csv(b$datapath, stringsAsFactors = F))
    }
    
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
  
  output$conc_up <- renderUI({fileInput("conc_up", "") })
  
  st.conc.table <- reactive({
    
    st.conc.table <- left_join(em.table(), disp.table())
    
    names(st.conc.table) <- c("Stack", "Pollutant", "CAS", "hr_PTE", "an_PTE", "hr_disp", "mon_disp", "an_disp")
    
    st.conc.table <- group_by(st.conc.table, Stack, Pollutant, CAS) %>%
                     summarize(hr_max = signif(hr_PTE * hr_disp * 453.592 / 3600, 4),
                               month_max = signif(an_PTE * mon_disp * 2000 * 453.592 / 8760 / 3600, 4),
                               annual_max = signif(an_PTE * an_disp * 2000 * 453.592 / 8760 / 3600, 4))
    
    names(st.conc.table) <- c("Stack ID", "Pollutant", "CAS", "1-hr Max", "Month Max", "Annual Max")
  
    st.conc.table
    })
  
  output$st_conc_table <- DT::renderDataTable(st.conc.table(), options=list(searching=F, paging=F, scrollX=T), rownames = FALSE)
  
  
  conc.table <- reactive({
    
    conc.table <- st.conc.table()
    
    names(conc.table) <- c("Stack", "Pollutant", "CAS", "hr", "mon", "an")
    
    group_by(conc.table, Pollutant, CAS) %>%
        summarize("1-hr Max" = sum(hr, na.rm=T),
                  "Month Max" = sum(mon, na.rm=T),
                  "Annual Max" = sum(an, na.rm=T))
    
    #names(conc.table) <- c("Pollutant", "CAS#", "1-hr Max", "Month Max", "Annual Max")
  })
  
  output$conc_table <- DT::renderDataTable(conc.table(), options=list(searching=F, paging=F, scrollX=T), rownames = FALSE)
   
  ####################
  # Risk tables
  ####################
  risk.table <- reactive({
    if(!is.null(conc.table())){   
      
      risk_table <- left_join(conc.table(), tox_values)
      
      risk_table <- left_join(risk_table, mpsf[ ,-2])
  
      risk_table$"Acute 1-hr Hazard Quotient (Air)" <- (risk_table[ ,3]/risk_table[ ,6])[[1]]
      risk_table$"Subchronic Hazard Quotient (Air)" <- (risk_table[ ,4]/risk_table[ ,7])[[1]]
      risk_table$"Longterm Hazard Quotient (Air)"   <- (risk_table[ ,5]/risk_table[ ,8])[[1]]
      risk_table$"Longterm Cancer Risk (Air)"       <- (risk_table[ ,5]/risk_table[ ,9])[[1]]
      
      risk_table <- risk_table[ , c(1:2,16:19,10:15)]
      
      # Multi-media
      risk_table$"Resident Longterm Hazard Quotient (All media)" <- (risk_table[ ,5]*(1+risk_table[ ,7]))[[1]]
      risk_table$"Resdident Longterm Cancer Risk (All media)"    <- (risk_table[ ,6]*(1+risk_table[ ,8]))[[1]]
      risk_table$"Urban Gardener Longterm Hazard Quotient (All media)" <- (risk_table[ ,5]*(1+risk_table[ ,9]))[[1]]
      risk_table$"Urban Gardener Longterm Cancer Risk (All media)" <- (risk_table[ ,6]*(1+risk_table[ ,10]))[[1]]
      risk_table$"Farmer Hazard Quotient (All media)" <- (risk_table[ ,5]*(1+risk_table[ ,11]))[[1]]
      risk_table$"Farmer Longterm Cancer Risk (All media)" <- (risk_table[ ,6]*(1+risk_table[ ,12]))[[1]]
      
      risk_table <- risk_table[ , -c(7:12)]
      
    } else {
      risk_table <- data.frame("Pollutant", "CAS", "Acute 1-hr Hazard Quotient (Air)", "Subchronic Hazard Quotient (Air)", "Longterm Hazard Quotient (Air)", "Longterm Cancer Risk (Air)", "Resident Longterm Hazard Quotient (All media)", "Resdident Longterm Cancer Risk (All media)", "Urban Gardener Longterm Hazard Quotient (All media)", "Urban Gardener Longterm Cancer Risk (All media)","Farmer Hazard Quotient (All media)", "Farmer Longterm Cancer Risk (All media)", check.names=F)
    }
    
    return(risk_table)
  })
  
  # Pollutant risk table
  pollutant.risk.table <- reactive({
    pol_risk <- risk.table()
    
    for(i in c(3:5,7,9,11)) {pol_risk[ ,i] <- round(pol_risk[ ,i], digits=2)}
    
    for(i in c(6,8,10,12)) {pol_risk[ ,i] <- format(signif(pol_risk[ ,i], digits=2), scientific=T)}
    
    pol_risk
    
  })
  
  output$air_risk_table <- DT::renderDataTable(pollutant.risk.table()[ ,1:6], options=list(searching=F, paging=F, scrollX=F), rownames = FALSE, class="compact")
  output$media_risk_table <- DT::renderDataTable(pollutant.risk.table()[ ,c(1:2,7:12)], options=list(searching=F, paging=F, scrollX=F), rownames = FALSE)
  
  # Total risk table
  total.risk.table <- reactive({
    
    total_risk <- risk.table()
    
    if(!is.null(total_risk)){   
      total_risk <- data.frame(
        "Acute 1-hr Hazard Quotient (Air)" = sum(total_risk[ ,3], na.rm=T), 
        "Subchronic Hazard Quotient (Air)" = sum(total_risk[ ,4], na.rm=T), 
        "Longterm Hazard Quotient (Air)"   = sum(total_risk[ ,5], na.rm=T), 
        "Longterm Cancer Risk (Air)"       = sum(total_risk[ ,6], na.rm=T), 
        "Resident Longterm Hazard Quotient (All media)"       = sum(total_risk[ ,7], na.rm=T),
        "Resdident Longterm Cancer Risk (All media)"          = sum(total_risk[ ,8], na.rm=T),
        "Urban Gardener Longterm Hazard Quotient (All media)" = sum(total_risk[ ,9], na.rm=T),
        "Urban Gardener Longterm Cancer Risk (All media)"     = sum(total_risk[ ,10], na.rm=T),
        "Farmer Hazard Quotient (All media)"                  = sum(total_risk[ ,11], na.rm=T), 
        "Farmer Longterm Cancer Risk (All media)"             = sum(total_risk[ ,12], na.rm=T), 
        check.names=F)  
      
      for(i in c(1:3,5,7,9)) {total_risk[ ,i] <- round(total_risk[ ,i], digits=2)}
      
      for(i in c(4,6,8,10)) {total_risk[ ,i] <- format(signif(total_risk[ ,i], digits=2), scientific=T)}
      
    } else {total_risk <- data.frame("Acute 1-hr Hazard Quotient (Air)", "Subchronic Hazard Quotient (Air)", "Longterm Hazard Quotient (Air)", "Longterm Cancer Risk (Air)", "Resident Longterm Hazard Quotient (All media)", "Resdident Longterm Cancer Risk (All media)", "Urban Gardener Longterm Hazard Quotient (All media)", "Urban Gardener Longterm Cancer Risk (All media)","Farmer Hazard Quotient (All media)", "Farmer Longterm Cancer Risk (All media)", check.names=F)}
    
    return(total_risk)
    })

  output$total_air_risk_table <- DT::renderDataTable(total.risk.table()[ ,1:4], options=list(searching=F, paging=F, scrollX=F, digits=2), rownames = FALSE)
  output$total_media_risk_table <- DT::renderDataTable(total.risk.table()[ ,5:10], options=list(searching=F, paging=F, scrollX=F, digits=2), rownames = FALSE)
  
  # Endpoint risk table
  endpoint.risk.table <- reactive({
    
    endpoint_risks <- data.frame(left_join(risk.table()[ ,1:5], endpoints), stringsAsFactors = F, check.names=F)
    
    print(endpoint_risks)
    print(!is.null(endpoint_risks) && nrow(endpoint_risks) > 0)
    
    if(!is.null(endpoint_risks) && nrow(endpoint_risks) > 0) {   
      end_risks <- data.frame("Endpoint" = c(
        "Auditory",
        "Blood/ hematological",
        "Bone & teeth",
        "Cardiovascular",
        "Digestive",
        "Ethanol specific",
        "Eyes",
        "Kidney",
        "Liver",
        "Neurological",
        "Reproductive/ developmental / endocrine",
        "Respiratory",
        "Skin"))
      
      end_risks$End_short <- substring(end_risks$Endpoint, 1, 4)
      
      for(i in 1:nrow(end_risks)) {
        end_risks$"Acute 1-hr Hazard Quotient (Air)"[i] <- sum(filter(endpoint_risks, grepl(end_risks$End_short[i], Acute_Toxic_Endpoints) | Acute_Toxic_Endpoints == "Systemic")$"Acute 1-hr Hazard Quotient (Air)", na.rm=T) 
        end_risks$"Subchronic Hazard Quotient (Air)"[i] <- sum(filter(endpoint_risks, grepl(end_risks$End_short[i], Subchronic_Toxic_Endpoints) | Subchronic_Toxic_Endpoints == "Systemic")$"Subchronic Hazard Quotient (Air)", na.rm=T) 
        end_risks$"Longterm Hazard Quotient (Air)"[i]   <- sum(filter(endpoint_risks, grepl(end_risks$End_short[i], Chronic_Noncancer_Endpoints) | Chronic_Noncancer_Endpoints == "Systemic")$"Longterm Hazard Quotient (Air)", na.rm=T) 
      }
      
      end_risks[ ,2] <- NULL
      
      for(i in 2:3) {
        end_risks[ ,i] <- round(end_risks[ ,i], digits = 2)
        end_risks[ ,i] <- ifelse(as.numeric(end_risks[ ,i]) < 0.0001, NA, end_risks[ ,i])
      }
      
      end_risks[ ,4] <- format(signif(end_risks[ ,4], digits=2), scientific=T)
      end_risks[ ,4] <- ifelse(as.numeric(end_risks[ ,4]) < 0.0001, NA, end_risks[ ,4])
      
    } else {end_risks  <- data.frame("Acute 1-hr Hazard Quotient (Air)", "Subchronic Hazard Quotient (Air)", "Longterm Hazard Quotient (Air)", check.names=F)}
    
    return(end_risks)
  })
  
  output$endpoint_risk_table <- DT::renderDataTable(endpoint.risk.table(), options=list(searching=F, paging=F, scrollX=F), rownames = FALSE)
 
  # Pollutants of concern
  pbts <- reactive({
    pbt_table <- left_join(em.table(), endpoints[ ,-c(3:5)])
    
    pbt_table <- filter(pbt_table, Persistent_Bioaccumulative_Toxicants > 0)[ , 2:3]
    
    names(pbt_table)[1] <- "PBT Pollutants"
    
    #if(nrow(pbt_table) < 1) pbt_table[1, ] <- " "
    unique(pbt_table)
    
  })
  
  output$pbt_table <- DT::renderDataTable(pbts(), options=list(searching=F, paging=F, scrollX=F), rownames = FALSE)
  
  # Developmental
  develop.tox <- reactive({
    develop_tox <- left_join(em.table(), endpoints[ ,-c(3:5)])
    
    develop_tox <- filter(develop_tox, Developmental_Toxicants > 0)[ , 2:3]
    
    names(develop_tox)[1] <- "Developmental Pollutant"
    
    unique(develop_tox)
    
  })
  
  output$develop_table <- DT::renderDataTable(develop.tox(), options=list(searching=F, paging=F, scrollX=F), rownames = FALSE)
  
  # Sensitizers
  sensitive.tox <- reactive({
    sensitive_tox <- left_join(em.table(), endpoints[ ,-c(3:5)])
    
    sensitive_tox <- filter(sensitive_tox, Developmental_Toxicants > 0)[ , 2:3]
    
    names(sensitive_tox)[1] <- "Respiratory sensitizing pollutants"
    
    unique(sensitive_tox)
    
  })
  
  output$sensitive_table <- DT::renderDataTable(sensitive.tox(), options=list(searching=F, paging=F, scrollX=F), rownames = FALSE)
   
  ########################
  # SAVE
  ########################
  
  #Download Buttons
  output$download_risk <- downloadHandler(
    filename = function() { paste0("RASS_Results_", Sys.Date(), ".csv", sep="") },
    content = function(con) {
      out_file = total.risk.table()
      write.csv(out_file, con, row.names=F)
    })
      
  output$download_inputs <- downloadHandler(
        filename = function() { paste0("RASS_Inputs_2016_.csv", Sys.Date(), ".csv", sep="") },
        content = function(con) {
                   out_file = total.risk.table()
                   write.csv(out_file, con, row.names=F)
   })
  
  ########################
  # MORE
  #######################
  output$tox_table <- DT::renderDataTable(tox_values, options=list(searching=F, paging=F, scrollX=T), rownames = FALSE)
  
  output$endpoints <- DT::renderDataTable(endpoints, options=list(searching=F, paging=F, scrollX=T), rownames = FALSE)
  
  
})
