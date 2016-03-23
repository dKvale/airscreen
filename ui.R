
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

shinyUI(navbarPage("Facility Air Screen",
                   
tabPanel("Stacks", 
        # Collect stack parameters
        h3("  Stack Parameters"), hr(style="margin-top:0px;"),
        column(8, h4("Input height and distance from fenceline", style="margin-botom:0px; padding-bottom:0px;"), 
               p("Enter height and distance in feet.", style="font-style: italic;"), br(),
               dataTableOutput("stack_table"), hr(), 
               p("Optional: Upload stack infromation as a comma seperated text file (.CSV).", style="margin-botom:-20px; padding-bottom:-10px;"), 
               uiOutput("stack_up"), hr())
        ),
                   
tabPanel("Dispersion", 
         # Collect dispersion factors
         h3("  Dispersion Factors"), hr(style="margin-top:0px;"),
         column(8, h4("Input air dispersion factors", style="margin-botom:0px; padding-bottom:0px;"), p("When dispersion factors are left blank they will be calculated based on stack height and fenceline distance.", style="font-style: italic;"), 
         p("Option 1: Use comma separated text to enter modeled disperson factors."), 
         p(" ", style="height:12px;"),   
         p("| Stack Name | 1-Hour Max | Highest Month Average | Highest Year Average |"),
         tags$textarea(id='disps', placeholder='Stack1,89,20,12', rows=5, 'Stack1,89,20,12\nStack2,70,19,14'),  
         tags$head(tags$style(type="text/css", "#disps {width:98%; background-color:#e6e6e6;}")), hr(), 
         p("Optional: Upload dispersion factors as a comma seperated text file (.CSV).", style="margin-botom:-20px; padding-bottom:0px;"), 
         uiOutput("disp_up"), hr(),
         h4("Dispersion factors", style="margin:0px; padding:0px;"), 
         dataTableOutput("disp_table"))
         ),
                   
                   
tabPanel("Emissions", 
         # Collect emission information        
         h3("  Emissions"), hr(style="margin-top:0px;"),
         # Pollutant Reference
         fluidRow(column(1, h4("CAS# Reference: ", style="margin-top:2px; padding:0px; margin-right: 100px; padding-right: 90px; width: 90%; margin-bottom:0px;")), 
                  column(4, uiOutput("pollutants"), tags$head(tags$style(type="text/css", "#pollutants {margin:0px; margin-top: -16px; padding:0px; padding-left:30px; width: 90%;"))), 
                  column(7)),
         tabsetPanel(          
         # Hourly emission rate 
         tabPanel("Hourly Emissions",
           column(8, br(),
                p("Enter maximum hourly emissions in pounds per hour. Add additional pollutants on a new line. For stacks not emitting a pollutant enter zero."), 
                dataTableOutput("hr_emissions_table")),
                p("  ", style="height: 1px; width:20px"), 
                p("Optional: Upload hourly emissions as a comma separated text file (.CSV).", style="margin-botom:-20px; padding-bottom:0px;"),
                uiOutput("hr_emissions_up"), hr()),
                       
          # Annual emission rate
          tabPanel("Annual Emissions",
            column(8, br(),
                 p("Option 1: Use comma separated text to enter the years total emissions in tons per year. Add additional pollutants on a new line. For stacks not emitting a pollutant enter zero."), 
                 p("| Pollutant | CAS# | Stack1 (tons/yr) | Stack2 (tons/yr) | Stack3..."), 
                 tags$textarea(id='ann_emissions', placeholder='Arsenic,7440-38-2,28,15', rows=5, 'Arsenic,7440-38-2,28,15\nBenzene,71-43-2,42,16'), 
                 tags$head(tags$style(type="text/css", "#ann_emissions {width:98%; background-color:#e6e6e6;}")), hr(),
                 p("  ", style="height:1px; width:20px"), 
                 p("Option 2: Upload annual emissions as a comma seperated text file (.CSV).", style="margin-botom:-20px; padding-bottom: 0px;"), 
                 uiOutput("ann_emissions_up"), hr(),
                 h4("Annual emissions", style="margin:0px; padding:0px;"),
                 dataTableOutput("ann_emissions_table")),
          column(1, p(" ", style="height: 12px; width:45px; margin-right:25px; padding-right:15px;"))
          ))),
              
              
tabPanel("Air Concentrations", 
         # Show concentrations 
         h3("  Maximum Air Concentrations"), hr(style="margin-top:0px;"),
         dataTableOutput("conc_table")
         ),
              
 
tabPanel("Risks", 
         # Show risk results 
         h3("  Risk Estimates"), hr(style="margin-top:0px;"), 
         h4("Total Facility Risks", style="margin:0px; padding:0px; margin-bottom:-25px;"), dataTableOutput("total.risk.table"),
         hr(style="margin-top:5px;"),
         h4("Pollutant Risks", style="margin:0px; padding:0px; margin-bottom:-25px;"), dataTableOutput("risk.table")),
              

tabPanel("Download / Save",

         h3("  Download Results"), hr(style="margin-top:0px;"),
        
         # SAVE options
                         
         # Enter facility name
         fluidRow(column(4, h4("Enter Facility Name and ID: ", style="margin-top:5px; padding:0px; margin-left:15px; padding-right:35px; width:100%; margin-bottom:2px;"), tags$textarea(id='Fname', placeholder='Facility name, ID#123456', rows=1), tags$head(tags$style(type="text/css", "#Fname {width:300px; background-color:'lightgrey'; margin-left:15px; margin-top:8px; padding-right:35px;}")))),
         fluidRow(column(3,br(), downloadButton("download", label = "  Download risk file", class = "download"), tags$style(type="text/css", "#download {margin-left:15px; margin-top:0px;}"))),
         br(),
         fluidRow(column(3,br(), downloadButton("download_inputs", label = "  Download facility inputs", class = "download")))
         )
)      
)
