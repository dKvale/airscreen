# 
# This is the server logic for the MPCA's air risk screening tool.
# 
# You can find out more about air pollution and risk assessment at
#           http://www.pca.state.mn.us/mvrifb5
#
# March 27th, 2015
library(shiny)
library(dplyr)
#library(rCharts)

tox_values <- read.csv("data//air_tox_values.csv", header=T, stringsAsFactors=F, nrows=500, check.names=F)
names(tox_values) <- c("CAS","Pollutant","Acute Reference Conc. (ug/m3)", "Subchronic Non-cancer Reference Conc. (ug/m3)", "Chronic Non-cancer Reference Conc. (ug/m3)", "Chronic cancer risk of 1E-5 Air Conc.(ug/m3)")

endpoints <- read.csv("data//air_tox_endpoints.csv", header=T, stringsAsFactors=F, nrows=500, check.names=F)
names(endpoints) <- c("CAS", "Pollutant", "Acute Toxic Endpoints", "Subchronic Toxic Endpoints", "Chronic Non-cancer Endpoints")

disp_facts <- read.csv("data//dispersion_factors.csv", header=T, stringsAsFactors=F, nrows=400, check.names=F)

mpsf <- read.csv("data//MPSFs.csv", header=T, stringsAsFactors=F, nrows=500, check.names=F)
names(mpsf)[1:2] <- c("CAS", "Pollutant")

pol_list <- paste0(tox_values$Pollutant," (", tox_values[ ,"CAS#"], ")")

shinyServer(function(input, output, session) {
  
  output$pollutants <- renderUI({selectizeInput("pollutant","", choices = pol_list, selected = "Acrolein (107-02-8)") })

  #################################
  # Stacks
  ################################
  
  output$stack_up <- renderUI({fileInput("stack_up", label=NULL) })
  
  stack.table <- reactive({
    data.frame("Stack ID" = c("Stack-1","Stack-2"), 
               "Stack Height" = c(99, 80), 
               "Distance To Fenceline" = c(55, 23), 
               check.names = F, stringsAsFactors = F)
  })
  
  output$stack_table <- renderDataTable(stack.table(), options=list(searching=F, paging=F, scrollX=T))
  
  ######################
  # Dispersion factors
  ######################
  output$disp_up <- renderUI({fileInput("disp_up", label=NULL) })
  
  disp.table <- reactive({
    if(!is.null(input$disp_up)) {
      d <- input$disp_up
      return(read.csv(d$datapath, stringsAsFactors=F))
    } else if(!is.null(stack.table())) { 
      disp_table <- data.frame("Stack ID" = stack.table()[ , 1], 
                               "1-Hour Max" = 1:nrow(stack.table()), 
                               "Monthly Max" = 1:nrow(stack.table()), 
                               "Annual Max" = 1:nrow(stack.table()), 
                               check.names=F, stringsAsFactors=F)
      for (stack in 1:nrow(disp_table)){
        nearD <- min(as.numeric(gsub("X","", names(disp_facts)[3:32]))[as.numeric(gsub("X","",names(disp_facts)[3:32]))>=round(stack.table()[stack, 3]/10,0)*10])
        if(stack.table()[stack, 3]>=10000) nearD <- 10000
        nearH <- min(round(stack.table()[stack, 2], 0), 99)
        disp_table[stack, 2:4] <- c(disp_facts[disp_facts$"Averaging.Time"=="1-hr" & disp_facts$"Stack.Height.meters"==nearH, paste0("X", nearD)],
                                    disp_facts[disp_facts$"Averaging.Time"=="monthly" & disp_facts$"Stack.Height.meters"==nearH, paste0("X", nearD)],
                                    disp_facts[disp_facts$"Averaging.Time"=="annual" & disp_facts$"Stack.Height.meters"==nearH, paste0("X", nearD)])
      }
    } else { 
      data.frame("Stack ID" = c("Stack-1","Stack-2"), 
                 "1-Hour Max" = c(1,2), 
                 "Montly Max" = c(.2,.34), 
                 "Annual Max" = c(.06,.15), 
                 check.names=F, stringsAsFactors=F)
    }
    return(disp_table[ ,1:4])
  })
  
  output$disp_table <- renderDataTable(disp.table(), options=list(searching=F, paging=F, scrollX=T))

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
    
    data.frame("Stack ID" = rep(c('Stack-1', 'Stack-2'), each = 2),
               "Pollutant" = rep(c("Arsenic","Benzene"), 2), 
               "CAS" = rep(c("7440-38-2","71-43-2"), 2), 
               "1-hr PTE Emissions (lbs/hr)" = c(1.0, 1.1, 2.2, 2.5),
               "Annual PTE Emissions (tons/yr)" = c(8, 10, 15, 19),
               check.names=F, stringsAsFactors=F)
  })
  
  output$emissions_table <- renderDataTable(em.table(), options=list(searching=F, paging=F, scrollX=F))
  
  #######################
  # Concentration tables
  #######################
  #output$conc_up <- renderUI({fileInput("conc_up", "") })
  st.conc.table <- reactive({
    
    st.conc.table <- left_join(em.table(), disp.table())
    
    names(st.conc.table) <- c("Stack", "Pollutant", "CAS", "hr_PTE", "an_PTE", "hr_disp", "mon_disp", "an_disp")
    
    print(st.conc.table)
    
    st.conc.table <- group_by(st.conc.table, Stack, Pollutant, CAS) %>%
                     summarize(hr_max = sum(hr_PTE * hr_disp, na.rm=T),
                               month_max = sum(hr_PTE * mon_disp, na.rm=T),
                               annual_max = sum(an_PTE * an_disp, na.rm=T))
    
    names(st.conc.table) <- c("Stack ID", "Pollutant", "CAS", "1-hr Max", "Month Max", "Annual Max")
  
    st.conc.table
    })
  
  output$st_conc_table <- renderDataTable(st.conc.table(), options=list(searching=F, paging=F, scrollX=T))
  
  
  conc.table <- reactive({
    
    conc.table <- st.conc.table()
    
    names(conc.table) <- c("Stack", "Pollutant", "CAS", "hr", "mon", "an")
    
    conc.table <- group_by(conc.table, Pollutant, CAS) %>%
                  summarize("1-hr Max" = sum(hr, na.rm=T),
                            "Month Max" = sum(mon, na.rm=T),
                            "Annual Max" = sum(an, na.rm=T))
    
    #names(conc.table) <- c("Pollutant", "CAS#", "1-hr Max", "Month Max", "Annual Max")
  })
  
  output$conc_table <- renderDataTable(conc.table(), options=list(searching=F, paging=F, scrollX=T))
   
  ####################
  # Risk tables
  ####################
  st.risk.table <- reactive({
    if(!is.null(conc.table())){   
      
      #print(as.character(conc.table()[,"CAS#"]) %in% as.character(tox_values[,"CAS#"]))
      risk.table <- left_join(st.conc.table(), tox_values)
      
      risk.table <- left_join(risk.table, mpsf[,-2])
      #risk.table[ ,3:15] <- lapply(risk.table[ ,3:15], function(x) as.numeric(as.character(x)))
      
      rrisk.table <- mutate(risk.table, 
                            "Acute 1-hr Hazard Quotient (Inhalation only)"= signif(risk.table[ ,3]/risk.table[ ,6], digits=3),
                            "Subchronic Hazard Quotient (Inhalation only)"= signif(risk.table[ ,4]/risk.table[ ,7], digits=3),
                            "Longterm Hazard Quotient (Inhalation only)"= signif(risk.table[ ,5]/risk.table[ ,8], digits=3),
                            "Longterm Cancer Risk (Inhalation only)"= signif(risk.table[ ,5]/risk.table[ ,9]/100000, digits=2), check.names=F, stringsAsFactors=F)
      
      risk.table2 <- mutate(risk.table2,
                            "Resident Longterm Hazard Quotient (All media)"= signif(risk.table2[ ,5]*(1+risk.table[ ,12]), digits=3),
                            "Resdident Longterm Cancer Risk (All media)"= format(signif(risk.table2[ ,6]*(1+risk.table[ ,13]),digits=2), scientific=T),
                            "Urban Gardener Longterm Hazard Quotient (All media)"= signif(risk.table2[ ,5]*(1+risk.table[ ,14]), digits=3),
                            "Urban Gardener Longterm Cancer Risk (All media)"= format(signif(risk.table2[ ,6]*(1+risk.table[ ,15]),digits=2), scientific=T),
                            "Farmer Hazard Quotient (All media)"= signif(risk.table2[ ,5]*(1+risk.table[ ,10]), digits=3),
                            "Farmer Longterm Cancer Risk (All media)"= format(signif(risk.table2[ ,6]*(1+risk.table[ ,11]),digits=2), scientific=T)) 
      risk.table2[ ,6] <- format(risk.table2[ ,6], scientific=T)
    } else {
      risk.table <- data.frame("Pollutant", "CAS#", "Acute 1-hr Hazard Quotient (Inhalation only)", "Subchronic Hazard Quotient (Inhalation only)", "Longterm Hazard Quotient (Inhalation only)", "Longterm Cancer Risk (Inhalation only)", "Resident Longterm Hazard Quotient (All media)", "Resdident Longterm Cancer Risk (All media)", "Urban Gardener Longterm Hazard Quotient (All media)", "Urban Gardener Longterm Cancer Risk (All media)","Farmer Hazard Quotient (All media)", "Farmer Longterm Cancer Risk (All media)", check.names=F)
    }
    
    return(risk.table2[ ,1:12])
  })
  
  #Total risk table
  total.risk.table <- reactive({
    risk.table <- risk.table()
    if(!is.null(risk.table())){   
      total.risk.table <- data.frame(
        "Acute 1-hr Hazard Quotient (Air)"=round(sum(risk.table[ ,3], na.rm=T), digits=2), 
        "Subchronic Hazard Quotient (Air)"=round(sum(risk.table[ ,4], na.rm=T), digits=2), 
        "Longterm Hazard Quotient (Air)"=round(sum(risk.table[ ,5], na.rm=T), digits=2),
        "Longterm Cancer Risk (Air)"=format(signif(sum(as.numeric(risk.table[ ,6]), na.rm=T), digits=2), scientific=T), 
        "Resident Longterm Hazard Quotient (All media)"=round(sum(risk.table[ ,7], na.rm=T), digits=2), 
        "Resdident Longterm Cancer Risk (All media)"=format(signif(sum(as.numeric(risk.table[ ,8]), na.rm=T), digits=2), scientific=T),
        "Urban Gardener Longterm Hazard Quotient (All media)"=round(sum(risk.table[ ,9], na.rm=T), digits=2),
        "Urban Gardener Longterm Cancer Risk (All media)"=format(signif(sum(as.numeric(risk.table[ ,10]), na.rm=T), digits=2), scientific=T),
        "Farmer Hazard Quotient (All media)"=round(sum(risk.table[ ,11], na.rm=T), digits=2), 
        "Farmer Longterm Cancer Risk (All media)"=format(signif(sum(as.numeric(risk.table[ ,12]), na.rm=T), digits=2), scientific=T), check.names=F)   
    } else {total.risk.table <- data.frame("Acute 1-hr Hazard Quotient (Inhalation only)", "Subchronic Hazard Quotient (Inhalation only)", "Longterm Hazard Quotient (Inhalation only)", "Longterm Cancer Risk (Inhalation only)", "Resident Longterm Hazard Quotient (All media)", "Resdident Longterm Cancer Risk (All media)", "Urban Gardener Longterm Hazard Quotient (All media)", "Urban Gardener Longterm Cancer Risk (All media)","Farmer Hazard Quotient (All media)", "Farmer Longterm Cancer Risk (All media)", check.names=F)
    return(total.risk.table[ ,1:10])
    }})
  
  output$risk_table <- renderDataTable(risk.table(), options=list(searching=F, paging=F, scrollX=T))
  
  output$total_risk_table <- renderDataTable(total.risk.table(), options=list(searching=F, paging=F, scrollX=T, digits=2))
  
  #Download Buttons
  output$download <- downloadHandler(
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
  
  output$tox_table <- renderDataTable(tox_values, options=list(searching=F, paging=F, scrollX=T))
  
  output$tox_points <- renderDataTable(endpoints, options=list(searching=F, paging=F, scrollX=T))
  
  
})
