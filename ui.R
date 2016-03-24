
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

tabPanel("Home", 
    # Collect stack parameters
    h3("  Select a facility:"), hr(style="margin-top:0px;"),
     column(8, h4("Enter a new facility:", style="margin-botom:0px; padding-bottom:0px;"), 
     br(),
     p("Optional: Select facility.", style="margin-botom:-20px; padding-bottom:-10px;")
     )),
                                      
tabPanel("Stacks", 
        # Collect stack parameters
        h3("  Stack Parameters"), hr(style="margin-top:0px;"),
        column(8, h4("Input height and distance from fenceline", style="margin-botom:0px; padding-bottom:0px;"), 
               p("Enter height and distance in feet.", style="font-style: italic;"), br(),
               dataTableOutput("stack_table"), hr(), 
               p("Optional: Upload stack infromation as an Excel file (.xlsx) or comma seperated text file (.csv).", style="margin-botom:-20px; padding-bottom:-10px;"), 
               uiOutput("stack_up"), hr())
        ),
                   
tabPanel("Dispersion", 
         # Collect dispersion factors
         h3("  Dispersion Factors"), hr(style="margin-top:0px;"),
         column(8, h4("Input air dispersion factors", style="margin-botom:0px; padding-bottom:0px;"), 
                p("If dispersion factors are left blank they will be calculated based on stack height and fenceline distance.", style="font-style: italic;"), 
                dataTableOutput("disp_table"), hr(), 
                p("Optional: Upload dispersion factors as an Excel file (.xlsx) or comma seperated text file (.csv).", style="margin-botom:-20px; padding-bottom:0px;"), 
                uiOutput("disp_up"), hr())
         ),
                   
                   
tabPanel("Emissions", 
         # Collect emission information        
         h3("  Emissions"), hr(style="margin-top:0px;"),
         # Pollutant Reference
         fluidRow(column(3, h4("Add pollutant: ", style="margin-top:13px; padding:0px; margin-right: 20px; padding-right: 0px; width: 100%; margin-bottom:0px;")), 
                  column(4, uiOutput("pollutants"), tags$head(tags$style(type="text/css", "#pollutants {margin:0px; margin-top: -16px; padding:0px; margin-left:-100px; width: 90%;"))), 
                  column(7)),
         
         tabsetPanel(          
         # Hourly emission rate 
         tabPanel("Hourly Emissions",
           column(12, br(),
                p("Enter maximum hourly emissions in lbs/hr. Add additional pollutants on a new line."), 
                br(),
                dataTableOutput("hr_emissions_table"),
                hr(), 
                p("Optional: Upload hourly emissions as an Excel file (.xlsx) or comma separated text file (.csv).", style="margin-botom:-20px; padding-bottom:0px;"),
                uiOutput("hr_emissions_up"), hr())),
                       
          # Annual emission rate
          tabPanel("Annual Emissions",
            column(8, br(),
                 p("Enter maximum annual emissions in tons/year. Add additional pollutants on a new line."),
                 br(),
                 dataTableOutput("ann_emissions_table"),
                 hr(),
                 p("Optional: Upload annual emissions as an Excel file (.xlsx) or comma seperated text file (.csv).", style="margin-botom:-20px; padding-bottom: 0px;"), 
                 uiOutput("ann_emissions_up"), hr()))
           )
         ),
              
              
tabPanel("Air Concentrations", 
         # Show concentrations 
         h3("  Maximum Air Concentrations"), hr(style="margin-top:0px;"),
         dataTableOutput("conc_table")
         ),
              
 
tabPanel("Risk Summary", 
         # Show risk results 
         h3("  Risk Summary"), hr(style="margin-top:0px;"), 
         tabsetPanel(
         tabPanel("Total Facility Risk", 
                  dataTableOutput("total.risk.table"),
                  hr(style="margin-top:5px;")
                  ),
         tabPanel("Pollutant Specific Risk", 
                  dataTableOutput("risk.table"),
                  hr(style="margin-top:5px;")
                  )
         )),
              

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
