
# This is the user-interface of the Facilty emissions web application.

inputTextarea <- function(inputId, value="", nrows, ncols) {
  tagList(
    singleton(tags$head(tags$script(src = "textarea.js"))),
    tags$textarea(id = inputId,
                  class = "inputtextarea",
                  rows = nrows,
                  cols = ncols,
                  as.character(value))
  )}

library(shiny)
library(stringr)

shinyUI(fluidPage(
  # Application title
  titlePanel("Facility Air Risk Assessment Screening Tool[beta]"),
  br(),
  
  tabsetPanel(tabPanel("Emissions", 
                       
                       # Collect emission information        
                       h3("  Emissions"), hr(style="margin-top:0px;"),
                       
                       # Pollutant Reference
                       fluidRow(column(1, h4("CAS# Reference: ", style="margin-top:2px; padding:0px; margin-right: 100px; padding-right: 90px; width: 90%; margin-bottom:0px;")), 
                                column(4, uiOutput("pollutants"), tags$head(tags$style(type="text/css", "#pollutants {margin:0px; margin-top: -16px; padding:0px; padding-left:30px; width: 90%;"))), 
                                column(7)),
                       
                       
                       # Hourly emission rate 
                       column(5, h4("Hourly emissions", style="margin-botom:0px; padding-bottom:0px;"), br(),
                              p("Option 1: Use comma separated text to enter maximum hourly emissions in pounds per hour. Add additional pollutants on a new line. For stacks not emitting a pollutant enter zero."), 
                              p("| Pollutant | CAS# | Stack1 (lbs/hour) | Stack2 (lbs/hour) | Stack3..."), 
                              tags$textarea(id='hr_emissions', placeholder='Arsenic,7440-38-2,1.4,1.6', rows=5, "Arsenic,7440-38-2,1.4,1.6\nBenzene,71-43-2,2.5,3.1"), tags$head(tags$style(type="text/css", "#hr_emissions {width: 98%; background-color:#e6e6e6;}")), hr(),
                              p("  ", style="height: 5px; width:20px"), 
                              
                              p("Option 2: Upload hourly emissions as a comma separated text file (.CSV).", style="margin-botom:-20px; padding-bottom:0px;"),
                              uiOutput("hr_emissions_up"), hr(),
                              h4("Hourly emissions", style="margin:0px; padding:0px;"),  
                              dataTableOutput("hr_emissions_table")),
                       
                       # Annual emission rate      
                       column(5, h4("Annual emissions", style="margin-botom:0px; padding-bottom:0px;"), br(),
                              p("Option 1: Use comma separated text to enter the years total emissions in tons per year. Add additional pollutants on a new line. For stacks not emitting a pollutant enter zero."), 
                              p("| Pollutant | CAS# | Stack1 (tons/yr) | Stack2 (tons/yr) | Stack3..."), 
                              tags$textarea(id='ann_emissions', placeholder='Arsenic,7440-38-2,28,15', rows=5, 'Arsenic,7440-38-2,28,15\nBenzene,71-43-2,42,16'), tags$head(tags$style(type="text/css", "#ann_emissions {width:98%; background-color:#e6e6e6;}")), hr(),
                              p("  ", style="height:5px; width:20px"), 
                              
                              p("Option 2: Upload annual emissions as a comma seperated text file (.CSV).", style="margin-botom:-20px; padding-bottom: 0px;"), 
                              uiOutput("ann_emissions_up"), hr(),
                              h4("Annual emissions", style="margin:0px; padding:0px;"),
                              dataTableOutput("ann_emissions_table")),
                       column(1, p(" ", style="height: 12px; width:45px; margin-right:25px; padding-right:15px;"))),
              
              
              tabPanel("Stacks", 
                       # Collect stack parameters
                       h3("  Stacks"), hr(style="margin-top:0px;"),
                       column(5, h4("Input height and distance from fenceline", style="margin-botom:0px; padding-bottom:0px;"), 
                              p("Enter height and distance in feet.", style="font-style: italic;"),br(), br(),
                              p("Option 1: Use comma separated text to enter stack height and distance from facility fenceline."), p("| Stack Name | Stack Height (ft) | Distance To Fenceline (ft) |"),
                              tags$textarea(id='stacks', placeholder='Stack1,99,55', rows=5, 'Stack1,99,55\nStack2,80,23' ), tags$head(tags$style(type="text/css", "#stacks {width:98%; background-color:#e6e6e6;}")), hr(), 
                              
                              p("Option 2: Upload stack infromation as a comma seperated text file (.CSV).", style="margin-botom:-20px; padding-bottom:-10px;"), 
                              uiOutput("stack_up"), hr(),
                              h4("Stack information", style="margin:0px; padding:0px;"),
                              dataTableOutput("stack_table")),
                       column(1, p(" ", style="height: 12px; width:45px; margin-right:25px; padding-right:15px;")),
                       
                       # Collect dispersion factors  
                       column(5, h4("Input air dispersion factors", style="margin-botom:0px; padding-bottom:0px;"), p("When dispersion factors are left blank they will be calculated based on stack height and fenceline distance.", style="font-style: italic;"), br(),
                              p("Option 1: Use comma separated text to enter modeled disperson factors."), 
                              p(" ", style="height:12px;"),   
                              p("| Stack Name | 1-Hour Max | Highest Month Average | Highest Year Average |"),
                              tags$textarea(id='disps', placeholder='Stack1,89,20,12', rows=5, 'Stack1,89,20,12\nStack2,70,19,14'),  
                              tags$head(tags$style(type="text/css", "#disps {width:98%; background-color:#e6e6e6;}")), hr(), 
                              
                              p("Option 2: Upload dispersion factors as a comma seperated text file (.CSV).", style="margin-botom:-20px; padding-bottom:0px;"), 
                              uiOutput("disp_up"), hr(),
                              h4("Dispersion factors", style="margin:0px; padding:0px;"), 
                              dataTableOutput("disp_table"))),
              
              # Concentrations 
              tabPanel("Air Concentrations", 
                       # Show risks
                       h3("  Air Concentrations"), hr(style="margin-top:0px;"),
                       
                       h4("Input air concentrations", style="margin-botom:0px; padding-bottom:0px;"), p("When air concentrations are left blank they will be calculated based on conservative modeling assumptions.", style="font-style: italic;"), br(),
                       p("Option 1: Use comma separated text to enter the maximum air concentration resulting from all stacks combined."), p("| Pollutant | CAS# | 1-Hour Max (ug/m3) | Highest Month  Average (ug/m3) | Highest Year Average (ug/m3) |"),
                       tags$textarea(id='concs', placeholder='Arsenic,7440-38-2,18,3,1.9', rows=7), tags$head(tags$style(type="text/css", "#concs {width:95%; min-width:200px; background-color:#e6e6e6; margin-top:-5px;}")), hr(), 
                       
                       p("Option 2: Upload maximum air concentrations as a comma seperated text file (.CSV).", style="margin:0px; margin-botom:-20px; padding-bottom:0px;"), 
                       uiOutput("conc_up"), hr(),
                       h4("Maximum air concentrations", style="margin:0px; padding:0px;"), 
                       dataTableOutput("conc_table")),
              
              # Risk results  
              tabPanel("Risks", 
                       # Show risks
                       h3("  Risk Estimates"), hr(style="margin-top:0px;"), 
                       h4("Total Facility Risks", style="margin:0px; padding:0px; margin-bottom:-25px;"), dataTableOutput("total.risk.table"),
                       hr(style="margin-top:5px;"),
                       h4("Pollutant Risks", style="margin:0px; padding:0px; margin-bottom:-25px;"), dataTableOutput("risk.table")),
              
              # Save Options
              tabPanel("Download",
                       h3("  Download Results"), hr(style="margin-top:0px;"),
                       
                       # Enter facility name
                       fluidRow(column(3, h4("Enter Facility Name and ID: ", style="margin-top:5px; padding:0px; margin-left:15px; padding-right:35px; width:100%; margin-bottom:2px;"), tags$textarea(id='Fname', placeholder='Facility name, ID#123456', rows=1), tags$head(tags$style(type="text/css", "#Fname {width:300px; background-color:'lightgrey'; margin-left:15px; margin-top:8px; padding-right:35px;}")))),
                       
                       fluidRow(column(3,br(), downloadButton("download", label = "  Download risk file", class = "download"), tags$style(type="text/css", "#download {margin-left:15px; margin-top:0px;}"))))
  )      
))
