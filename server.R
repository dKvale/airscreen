# 
# This is the server logic for the MPCA's air risk screening tool.
# 
# You can find out more about air pollution and risk assessment at
#           http://www.pca.state.mn.us/mvrifb5
#
# March 27th, 2015
library(shiny)
library(dplyr)
library(stringr)
library(rCharts)
#library(tidyr)

#options(scipen=+9999, digits=0)
tox_values <- read.csv("Air_tox_values.csv", header=T, stringsAsFactors=F, nrows=500, check.names=F)
names(tox_values)[c(3,7,27,20,15)] <- c("CAS#","Acute Reference Conc. (ug/m3)", "Subchronic Non-cancer Reference Conc. (ug/m3)", "Chronic Non-cancer Reference Conc. (ug/m3)", "Chronic cancer risk of 1E-5 Air Conc.(ug/m3)")
#for(name2 in names(tox_values)) {
#tox_values[ ,name2] <- str_trim(gsub("\xca", "", tox_values[ ,name2]))
#}
#write.csv(tox_values, "Air_tox_values.csv", row.names=F)

disp_facts <- read.csv("dispFactors.csv", header=T, stringsAsFactors=F, nrows=400, check.names=F)

#mpsf_old <- read.csv("MPSFs_old.csv", header=T, stringsAsFactors=F, nrows=500, check.names=F)
#names(mpsf_old)[1:2] <- c("CAS#", "Pollutant")
mpsf <- read.csv("MPSFs.csv", header=T, stringsAsFactors=F, nrows=500, check.names=F)
names(mpsf)[1:2] <- c("CAS#", "Pollutant")
#mpsf[is.na(mpsf)] <-0

pol_list <- paste0(tox_values$Pollutant.Name,", ", tox_values[ ,"CAS#"])

shinyServer(function(input, output, session) {
  
  output$pollutants <- renderUI({selectInput("pollutant","", choices=pol_list) })
  
  #################################
  # Emissions
  ################################
  output$hr_emissions_up <- renderUI({fileInput("hr_emissions_up", "") })
  
  hr.table <- reactive({
    data.frame("Pollutant" = c("Arsenic","Benzene"), 
               "CAS#" = c("7440-38-2","71-43-2"), 
               "Stack1 (lbs/hr)" = c(1.0,2.5), 
               "Stack2 (lbs/hr)" = c(2.2,3.1), 
               check.names=F, stringsAsFactors=F)
  })
  
  output$hr_emissions_table <- renderDataTable(hr.table(), 
                                               options=list(searching=F, paging=F, scrollX=T))
  
  #output$ann_emissions <- renderUI({textInput("ann_emissions","", ifelse(is.null(input$ann_emissions_up), "Arsenic, 7440-38-2, 1.4, 12 + Benzene, 71-43-2, 1.2, 23", "Reading uploaded file...")) })
  
  output$ann_emissions_up <- renderUI({fileInput("ann_emissions_up", "") })
  
  ann.table <- reactive({
    if(!is.null(input$ann_emissions_up)) {a<-input$ann_emissions_up
    return(read.csv(a$datapath,stringsAsFactors=F))
    }
    if(!is.null(input$ann_emissions)&length(unlist(strsplit(input$ann_emissions,"")))>3){   
      ann_table <- read.csv(text=input$ann_emissions, header=F, stringsAsFactors=F)
      names(ann_table)[1:2] <- c("Pollutant", "CAS#")
      for(N in 3:ncol(ann_table)) names(ann_table)[N] <- paste0("Stack", N-2, " (tons/yr)")
      return(ann_table) 
    } else data.frame("Pollutant"=c("Arsenic","Benzene"), "CAS#"=c("7440-38-2","71-43-2"), "Stack1 (tons/yr)"=c(28,42), "Stack2 (tons/yr)"=c(12,16), check.names=F, stringsAsFactors=F)
  })
  output$ann_emissions_table <- renderDataTable(ann.table(), options=list(searching=F, paging=F, scrollX=T))
  
  #################################
  # Stacks
  ################################
  
  output$stack_up <- renderUI({fileInput("stack_up", "") })
  
  stack.table <- reactive({
    data.frame("Stack Name" = c("Stack1","Stack2"), 
               "Stack Height (ft)" = c(99,80), 
               "Distance To Fenceline (ft)" = c(55,23), 
               check.names = F, stringsAsFactors = F)
  })
  
  output$stack_table <- renderDataTable(stack.table(), options=list(searching=F, paging=F, scrollX=T))
  
  # Dispersion factors
  output$disp_up <- renderUI({fileInput("disp_up", "") })
  
  disp.table <- reactive({
    if(!is.null(input$disp_up)) {d<-input$disp_up
    return(read.csv(d$datapath, stringsAsFactors=F))
    }
    if(!is.null(input$disps) && length(unlist(strsplit(input$disps,"")))>3){   
      disp_table <- read.csv(text=input$disps, header=F, stringsAsFactors=F)
      names(disp_table)[1:4] <- c("Stack Name", "1-Hour Max", "Highest Month Average", "Highest Year Average")   
    } else if(!is.null(stack.table())) { disp_table <- data.frame("Stack Name"=stack.table()[ ,1], "1-Hour Max"=1:nrow(stack.table()), "Highest Month Average"=1:nrow(stack.table()), "Highest Year Average"=1:nrow(stack.table()), check.names=F, stringsAsFactors=F)
    for (stack in 1:nrow(disp_table)){
      nearD <- min(as.numeric(gsub("X","",names(disp_facts)[3:32]))[as.numeric(gsub("X","",names(disp_facts)[3:32]))>=round(stack.table()[stack, 3]/10,0)*10])
      if(stack.table()[stack, 3]>=10000) nearD <- 10000
      nearH <- min(round(stack.table()[stack, 2], 0), 99)
      disp_table[stack, 2:4] <- c(disp_facts[disp_facts$"Averaging.Time"=="1-hr" & disp_facts$"Stack.Height.meters"==nearH, paste0("X", nearD)],
                                  disp_facts[disp_facts$"Averaging.Time"=="monthly" & disp_facts$"Stack.Height.meters"==nearH, paste0("X", nearD)],
                                  disp_facts[disp_facts$"Averaging.Time"=="annual" & disp_facts$"Stack.Height.meters"==nearH, paste0("X", nearD)])
      
    }
    } else { data.frame("Stack Name"=c("Stack1","Stack2"), "1-Hour Max"=c(89,70), "Highest Month Average"=c(20,19), "Highest Year Average"=c(12,14), check.names=F, stringsAsFactors=F)
    }
    return(disp_table[ ,1:4])
  })
  
  output$disp_table <- renderDataTable(disp.table(), options=list(searching=F, paging=F, scrollX=T))
  
  #################################
  # Concentrations
  ################################ 
  # Concentration table
  #output$conc_up <- renderUI({fileInput("conc_up", "") })
  
  conc.table <- reactive({
    conc.table <- data.frame(Pollutant=arrange(ann.table(), Pollutant)$Pollutant, "CAS#"=as.character(arrange(ann.table(), Pollutant)[ ,"CAS#"]), "1-hr Max (ug/m3)"=1:nrow(ann.table()), "Highest Month Average (ug/m3)"=1:nrow(ann.table()), "Highest Year Average (ug/m3)"=1:nrow(ann.table()), check.names=F, stringsAsFactors=F)
    
    conc.table.hr  <- hr.table()
    conc.table.mn  <- ann.table()
    conc.table.ann <- ann.table()
    
    for(stack in 3:ncol(hr.table())) conc.table.hr[ ,stack] <- arrange(hr.table(), Pollutant)[ ,stack]*disp.table()[stack-2, 2]*453.592/3600
    for(stack in 3:ncol(ann.table())) conc.table.mn[ ,stack] <- arrange(ann.table(), Pollutant)[ ,stack]*disp.table()[stack-2, 3]*2000*453.592/3600/8765.81
    for(stack in 3:ncol(ann.table())) conc.table.ann[ ,stack] <- arrange(ann.table(), Pollutant)[ ,stack]*disp.table()[stack-2, 4]*2000*453.592/3600/8765.81
    for(pollutant in 1:nrow(conc.table)) conc.table[pollutant, 3] <- sum(conc.table.hr[pollutant,-c(1:2)], na.rm=T)
    for(pollutant in 1:nrow(conc.table)) conc.table[pollutant, 4] <- sum(conc.table.mn[pollutant,-c(1:2)], na.rm=T)
    for(pollutant in 1:nrow(conc.table)) conc.table[pollutant, 5] <- sum(conc.table.ann[pollutant,-c(1:2)], na.rm=T)
    conc.table[ ,2] <- as.character(conc.table[ ,2])
    conc.table[,3:5] <- signif(conc.table[,3:5], digits=4)
    return(conc.table[ ,1:5])
    })
  
  output$conc_table <- renderDataTable(conc.table(), options=list(searching=F, paging=F, scrollX=T))
  
  #################################
  # Risks
  ################################ 
  #Risk table
  risk.table <- reactive({
    if(!is.null(conc.table())){   
      #print(as.character(conc.table()[,"CAS#"]) %in% as.character(tox_values[,"CAS#"]))
      risk.table <- left_join(conc.table(), tox_values[ ,c(3,7,27,20,15)], by="CAS#")
      risk.table <- left_join(risk.table, mpsf[,-2], by="CAS#")
      #risk.table[ ,3:15] <- lapply(risk.table[ ,3:15], function(x) as.numeric(as.character(x)))
      
      risk.table2 <- data.frame("Pollutant"=as.character(risk.table$Pollutant), "CAS#"=as.character(risk.table[ ,2]), 
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
    } else {risk.table2 <- data.frame("Pollutant", "CAS#", "Acute 1-hr Hazard Quotient (Inhalation only)", "Subchronic Hazard Quotient (Inhalation only)", "Longterm Hazard Quotient (Inhalation only)", "Longterm Cancer Risk (Inhalation only)", "Resident Longterm Hazard Quotient (All media)", "Resdident Longterm Cancer Risk (All media)", "Urban Gardener Longterm Hazard Quotient (All media)", "Urban Gardener Longterm Cancer Risk (All media)","Farmer Hazard Quotient (All media)", "Farmer Longterm Cancer Risk (All media)", check.names=F)
    }
    return(risk.table2[ ,1:12])
  })
  
  #Total risk table
  total.risk.table <- reactive({
    risk.table <- risk.table()
    if(!is.null(risk.table())){   
      total.risk.table <- data.frame(
        "Acute 1-hr Hazard Quotient (Inhalation only)"=round(sum(risk.table[ ,3], na.rm=T), digits=2), 
        "Subchronic Hazard Quotient (Inhalation only)"=round(sum(risk.table[ ,4], na.rm=T), digits=2), 
        "Longterm Hazard Quotient (Inhalation only)"=round(sum(risk.table[ ,5], na.rm=T), digits=2),
        "Longterm Cancer Risk (Inhalation only)"=format(signif(sum(as.numeric(risk.table[ ,6]), na.rm=T), digits=2), scientific=T), 
        "Resident Longterm Hazard Quotient (All media)"=round(sum(risk.table[ ,7], na.rm=T), digits=2), 
        "Resdident Longterm Cancer Risk (All media)"=format(signif(sum(as.numeric(risk.table[ ,8]), na.rm=T), digits=2), scientific=T),
        "Urban Gardener Longterm Hazard Quotient (All media)"=round(sum(risk.table[ ,9], na.rm=T), digits=2),
        "Urban Gardener Longterm Cancer Risk (All media)"=format(signif(sum(as.numeric(risk.table[ ,10]), na.rm=T), digits=2), scientific=T),
        "Farmer Hazard Quotient (All media)"=round(sum(risk.table[ ,11], na.rm=T), digits=2), 
        "Farmer Longterm Cancer Risk (All media)"=format(signif(sum(as.numeric(risk.table[ ,12]), na.rm=T), digits=2), scientific=T), check.names=F)   
    } else {total.risk.table <- data.frame("Acute 1-hr Hazard Quotient (Inhalation only)", "Subchronic Hazard Quotient (Inhalation only)", "Longterm Hazard Quotient (Inhalation only)", "Longterm Cancer Risk (Inhalation only)", "Resident Longterm Hazard Quotient (All media)", "Resdident Longterm Cancer Risk (All media)", "Urban Gardener Longterm Hazard Quotient (All media)", "Urban Gardener Longterm Cancer Risk (All media)","Farmer Hazard Quotient (All media)", "Farmer Longterm Cancer Risk (All media)", check.names=F)
    return(total.risk.table[ ,1:10])
    }})
  
  output$risk.table <- renderDataTable(risk.table(), options=list(searching=F, paging=F, scrollX=T))
  output$total.risk.table <- renderDataTable(total.risk.table(), options=list(searching=F, paging=F, scrollX=T, digits=2))
  
  #Download Button
  output$download <- downloadHandler(
    filename = function() { paste("MPCA_RASS_2015_",input$Fname, ".csv", sep="") },
    content = function(con) {
      out_file=total.risk.table()
      write.csv(out_file, con, row.names=F)
    })
      
  output$download_inputs <- downloadHandler(
        filename = function() { paste("MPCA_RASS_2015_",input$Fname, ".csv", sep="") },
        content = function(con) {
                   out_file = total.risk.table()
                   write.csv(out_file, con, row.names=F)
   })
  
})
