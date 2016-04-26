##
# This is the server logic for the MPCA's facility air risk screening tool.
# 
# You can find out more about air modeling and risk assessment at
#
#           http://www.pca.state.mn.us/mvrifb5
##
library(shiny)
library(dplyr)
library(leaflet)
library(DT)
library(readxl)
library(XLConnect)

source('global.R')

shinyServer(function(input, output, session) {
  
  #################################
  # Facility Map
  ################################
  fac.info <- reactive({
    
    req(input$master)

    col_names <- c("Facility Name",	"Facility ID#",	"Facility Address",	"Latitude",	"Longitude")
    
    in.file(input$master, 2, 5, col_names)
      
  })
  
  output$fac_name_UI <- renderUI({
    textInput('fac_name', label=NULL, placeholder=facility, value=facility)
  })
  
  output$address_UI <- renderUI({
    textInput('address', label=NULL, placeholder=address)
  })
  
  output$fac_lat_UI <- renderUI({
    textInput('lat', label=NULL, placeholder='46.29', value = '46.29')
  })
  
  output$fac_long_UI <- renderUI({
    textInput('long', label=NULL, placeholder='-96.063', value='-96.063')
  })
  
  observeEvent(input$master, {
    updateTextInput(session, 'fac_name', 
                    value= paste0(as.character(fac.info()[1, 1])[[1]], 
                                  " (#", as.character(fac.info()[1, 2])[[1]], 
                                  ")"))
    updateTextInput(session, 'address', value=fac.info()[1, 3][[1]])
    updateTextInput(session, 'lat', value=fac.info()[1, 4][[1]])
    updateTextInput(session, 'long', value=fac.info()[1, 5][[1]])
  })
  
  output$fac_map <- renderLeaflet({
    
    #invalidateLater(5000)
    xy <- coords
    fac_name <- facility
    #print(fac_name)
    #print(xy)
    
    if(!is.null(input$lat)) xy[1, 1] <- as.numeric(input$lat)
    if(!is.null(input$long)) xy[1, 2] <- as.numeric(input$long)
    if(!is.null(input$fac_name)) fac_name <- input$fac_name
    
    if (!is.null(input$master)) {print(fac.info())}
    print(xy)
    #print(fac_name)
    
    #mbToken <- ''
    #mbMap <- 'https://api.mapbox.com/v4/mapbox.streets/{z}/{x}/{y}.png'
    
    #mb2 <- paste0(mbMap, '?access_token=', mbToken)
    
    leaflet() %>% 
    addTiles() %>%
      addMarkers(data=xy, popup=fac_name) %>%
      addCircles(data=xy, weight = 1, fillColor= "orange", color="darkorange",
                 radius = 1500, popup = "1.5km impact radius") %>%
      addCircles(data=xy, weight = 1,
                 radius = min(stack.table()$"Distance to Fenceline", na.rm=T), popup = "Estimated property boundary")
    })

  #################################
  # Stacks
  ################################
  
  stack.table <- reactive({
    
    col_names <- c("Stack ID", "Stack Height", "Distance to Fenceline")
    
    if(!is.null(input$master)) { return(in.file(input$master, 3, 3, col_names)) }
    if(!is.null(input$stack_up))  { return(in.file(input$stack_up, 1, 3, col_names)) }
    
    ex_stacks
    
  })
  
  output$stack_table <- DT::renderDataTable(stack.table(), options=list(searching=F, paging=F, scrollX=T), rownames = FALSE)
  
  ######################
  # Dispersion factors
  ######################

  disp.table <- reactive({
    
    col_names <- c("Stack ID", "1-Hour Max", "Annual Max")
    
    if(!is.null(input$master)) { return(in.file(input$master, tab=4, n_col=3, col_names)) }
    
    if(!is.null(input$disp_up)) { return(in.file(input$disp_up, tab=1, n_col=3, col_names)) } 
      
    if(!is.null(stack.table())) { 
      
      stacks <- stack.table()
      
      n_stacks <- nrow(stacks)
      
      disp_table <- data.frame("Stack ID" = stacks[ , 1], 
                               "1-Hour Max"  = 1:n_stacks, 
                               "Annual Max"  = 1:n_stacks, 
                               check.names=F, stringsAsFactors=F)
      
      #if(input$st_units == "Feet") stacks$'Stack Height' <- stacks$'Stack Height' * 0.3048
      
      for(stack in 1:n_stacks) {
        nearD <- min(as.numeric(gsub("X","", names(disp_facts)[3:32]))[as.numeric(gsub("X", "", names(disp_facts)[3:32])) >= floor(stacks[stack, 3]/10)*10])
        
        if(stacks[stack, 3]>=10000) nearD <- 10000
        
        nearH <- min(round(stacks[stack, 2], 0), 99)
        
        disp_table[stack, 2:3] <- c(disp_facts[disp_facts$"Averaging.Time"=="1-hr" & disp_facts$"Stack.Height.meters" == nearH, paste0("X", nearD)],
                                    disp_facts[disp_facts$"Averaging.Time"=="annual" & disp_facts$"Stack.Height.meters" == nearH, paste0("X", nearD)])
      }
    } else { disp_table <- ex_dispersion }
      
    return(disp_table[ , 1:3])
  })
  
  output$disp_table <- DT::renderDataTable(disp.table(), options=list(searching=F, paging=F, scrollX=T), rownames = FALSE)

  #################################
  # Emissions
  ################################
  em.table <- reactive({
    
    col_names <- c("Stack ID", "Pollutant", "CAS", "1-hr PTE Emissions (lbs/hr)", "Annual PTE Emissions (tons/yr)")
    
    if(!is.null(input$master)) { return(in.file(input$master, tab=5, n_col=5, col_names)) }
    
    if(!is.null(input$emissions_up)) { return(in.file(input$emissions_up, tab=1, n_col=5, col_names)) }
      
    ex_emissions
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
  
    data.frame(st.conc.table, stringsAsFactors = F, check.names = F)
    })
  
  output$st_conc_table <- DT::renderDataTable(st.conc.table(), options=list(searching=F, paging=F, scrollX=T,  digits=1), rownames = FALSE)
  
  conc.table <- reactive({
    
    col_names <- c("Pollutant", "CAS", "1-hr Max", "Annual Max")
    
    if(!is.null(input$conc_up)) { return(in.file(input$conc_up, tab=1, n_col=4, col_names)) } 
    
    if(!is.null(input$master)) { 
      conc_table <- in.file(input$master, tab=6, n_col=4, col_names)
      
      if(nrow(conc_table) >= length(unique(em.table()$Pollutant))) return(conc_table)
       }
    
    conc.table <- st.conc.table()
    
    names(conc.table) <- c("Stack", "Pollutant", "CAS", "hr", "an")
    
    conc.table <- group_by(conc.table, Pollutant, CAS) %>%
                    summarize("1-hr Max" = sum(hr, na.rm=T),
                              "Annual Max" = sum(an, na.rm=T))
    
    data.frame(conc.table, stringsAsFactors = F, check.names = F)
  })
  
  output$conc_table <- DT::renderDataTable(conc.table(), options=list(searching=F, paging=F, scrollX=T, digits=2), rownames = FALSE)
   
  ####################
  # Risk tables
  ####################
  risk.table <- reactive({
    if(!is.null(conc.table())){   
      
      risk_table <- left_join(conc.table(), tox_values)
      
      risk_table <- data.frame(left_join(risk_table, mpsf[ ,-2]),
                               check.names=F, stringsAsFactors = F)
  
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
      risk_table <- data.frame(matrix(NA, nrow=1, ncol=12), check.names=F, stringsAsFactors=F)
    }
    
    names(risk_table) <- risk_table_names
    
    risk_table
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
  
  output$pollutant_risk_table <- DT::renderDataTable(pollutant.risk.table(), options=list(searching=F, paging=F, scrollX=F), rownames = FALSE)
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
    
    total_risk
    })

  output$total_air_risk_table <- DT::renderDataTable(total.risk.table()[ ,1:3], options=list(searching=F, paging=F, scrollX=F, columnDefs=list(list(targets=2, class="dt-right"))), rownames = FALSE)
  output$total_media_risk_table <- DT::renderDataTable(total.risk.table()[ ,c(4,6,8,5,7,9)], options=list(searching=F, paging=F, scrollX=F, columnDefs=list(list(targets=0:5, class="dt-right"))), rownames = FALSE)
  
  # Endpoint risk table
  endpoint.risk.table <- reactive({
    
    endpoint_risks <- left_join(risk.table()[ , 1:4], endpoints[ , 1:5])
    
    print(endpoint_risks)
    
    if(!is.null(endpoint_risks) & nrow(endpoint_risks) > 0) {   
      end_risks <- endpoints_list
      
      for(i in 1:nrow(end_risks)) {
        end_risks$"Acute 1-hr Hazard Quotient (Air)"[i] <- sum(filter(endpoint_risks, grepl(end_risks$End_short[i], `Acute Toxic Endpoints`) | `Acute Toxic Endpoints` == "Systemic")$"Acute 1-hr Hazard Quotient (Air)", na.rm=T) 
        end_risks$"Longterm Hazard Quotient (Air)"[i]   <- sum(filter(endpoint_risks, grepl(end_risks$End_short[i], `Chronic Noncancer Endpoints`) | `Chronic Noncancer Endpoints` == "Systemic")$"Longterm Hazard Quotient (Air)", na.rm=T) 
      }
      
      end_risks[ ,2] <- NULL
      
      print(end_risks)
      
      # Round acute risk
      end_risks[ ,2] <- round(end_risks[ ,2], digits = 2)
      end_risks[ ,2] <- ifelse(as.numeric(end_risks[ ,2]) < 0.0001, NA, end_risks[ ,2])
      
      # Set cancer digits
      end_risks[ ,3] <- format(signif(end_risks[ ,3], digits=2), scientific=T)
      end_risks[ ,3] <- ifelse(as.numeric(end_risks[ ,3]) < 0.0001, NA, end_risks[ ,3])
      
    } else {end_risks  <- data.frame("Acute 1-hr Hazard Quotient (Air)", "Subchronic Hazard Quotient (Air)", "Longterm Hazard Quotient (Air)", check.names=F)}
    
    data.frame(end_risks, stringsAsFactors = F, check.names = F)
  })
  
  output$endpoint_risk_table <- DT::renderDataTable(endpoint.risk.table(), options=list(searching=F, paging=F, scrollX=F, columnDefs=list(list(targets=1:2, class="dt-right"))), rownames = FALSE)
 
  # Pollutants of concern
  pbts <- reactive({
    pbt_table <- left_join(em.table(), endpoints[ ,-c(3:5)])
    
    pbt_table <- filter(pbt_table, `Persistent Bioaccumulative Toxicants` > 0)[ , 2:3]
    
    #names(pbt_table)[1] <- "PBT Pollutants"
    data.frame(unique(pbt_table), check.names=F, stringsAsFactors = F)
    
  })
  
  output$pbt_table <- DT::renderDataTable(pbts(), options=list(searching=F, paging=F, scrollX=F), rownames = FALSE)
  
  # Developmental
  develop.tox <- reactive({
    develop_tox <- left_join(em.table(), endpoints[ ,-c(3:5)])
    
    develop_tox <- filter(develop_tox, `Developmental Toxicants` > 0)[ , 2:3]
    
    #names(develop_tox)[1] <- "Developmental Pollutant"
    data.frame(unique(develop_tox), check.names=F, stringsAsFactors = F)

  })
  
  output$develop_table <- DT::renderDataTable(develop.tox(), options=list(searching=F, paging=F, scrollX=F), rownames = FALSE)
  
  # Sensitizers
  sensitive.tox <- reactive({
    sensitive_tox <- left_join(em.table(), endpoints[ ,-c(3:5)])
    
    sensitive_tox <- filter(sensitive_tox, `Respiratory Sensitizers` > 0)[ , 2:3]
    
    #names(sensitive_tox)[1] <- "Respiratory sensitizing pollutants"
    data.frame(unique(sensitive_tox), check.names=F, stringsAsFactors = F)
  })
  
  output$sensitive_table <- DT::renderDataTable(sensitive.tox(), options=list(searching=F, paging=F, scrollX=F), rownames = FALSE)
   
  ########################
  # SAVE
  ########################
  
  # Download Buttons
  output$download_inputs <- downloadHandler(
        filename = function() { 
          paste0("Fair screen summary - ", Sys.Date(), ".xlsx", sep="") 
          },
        content = function(file) {
         # fname <- paste(file,"xlsx",sep=".")
          wb <- loadWorkbook(file, create = TRUE)
          write_sheet(wb, "Facility Info", fac.info())
          
          write_sheet(wb, "Stack Parameters", stack.table())
          write_sheet(wb, "Dispersion Factors", disp.table()) 
          write_sheet(wb, "Emissions", em.table()) 
          write_sheet(wb, "Air Concentrations", conc.table()) 
          write_sheet(wb, "Total facility risk", total.risk.table())
          write_sheet(wb, "Pollutant risk", risk.table())
          write_sheet(wb, "Endpoint risk", endpoint.risk.table())
         
           write_sheet(wb, "Pollutants of concern", 
                         data.frame('PBTs' = pbts()[1:15,1],
                                    'Developmental Pollutants' = develop.tox()[1:15,1],
                                    'Respiratory Sensitizers' = sensitive.tox()[1:15,1],
                                    stringsAsFactors = F,
                                    check.names=F))
          
          write_sheet(wb, "Time stamp", 
                      data.frame('Fair Screen version#' = version,
                                    'Run date' = Sys.Date(),
                                    stringsAsFactors = F,
                                    check.names = F))
          
          saveWorkbook(wb, file) #file.rename(fname,file)
   })
  
  ########################
  # MORE
  #######################
  output$tox_table <- DT::renderDataTable(tox_values[ ,c(2,1,3:6)], options=list(searching=F, paging=F, scrollX=T), rownames = FALSE)
  
  output$endpoints <- DT::renderDataTable(endpoints[,c(2,1,3:5)], options=list(searching=F, paging=F, scrollX=T), rownames = FALSE)
  
  output$mpsf      <- DT::renderDataTable(mpsf[,c(2,1,3:8)], options=list(searching=F, paging=F, scrollX=T), rownames = FALSE)
  
})
