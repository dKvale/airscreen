
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

shinyUI(navbarPage("Facility Air Screen", theme = "bootstrap_readable.css",

tabPanel("Home", 
    # Collect stack parameters
    h3("Select a facility:"), hr(),
    br(),
    h3("Enter a new facility:"), hr(),
    br(),
    
    h3("Save risk summary"),
    fluidRow(
      column(5, textInput('Fname', label=NULL, placeholder='Enter file name: "Risk Summary 2016"')),
      column(3, downloadButton("download", label = "  Download risk summary", class="down_btn"))),
    br(), 
    hr(),
    
    h3("Save inputs"),
    fluidRow(
      column(5, textInput('Fname2', label=NULL, placeholder='Enter file name: "RASS Inputs 2016"')),
      column(3, downloadButton("download_inputs", label = "  Download facility inputs", class = "down_btn"))),
    br(), hr()
    ),
                                      
tabPanel("Stacks", 
        # Collect stack parameters
        h3("  Stack parameters"), hr(),
        column(8, h4("Input height and distance from fenceline", style="margin-botom:0px; padding-bottom:0px;"), 
               p("Enter height and distance in feet.", style="font-style: italic;"), br(),
               dataTableOutput("stack_table"), hr(), 
               p("Optional: Upload stack infromation as an Excel file (.xlsx) or comma seperated text file (.csv).", style="margin-botom:-20px; padding-bottom:-10px;"), 
               uiOutput("stack_up"), hr())
        ),
                   
tabPanel("Dispersion", 
         # Collect dispersion factors
         h3("  Dispersion factors"), hr(),
         column(8, h4("Input air dispersion factors", style="margin-botom:0px; padding-bottom:0px;"), 
                p("If dispersion factors are left blank, they are estimated based on stack height and fenceline distance.", style="font-style: italic;"), 
                dataTableOutput("disp_table"), hr(), 
                p("Optional: Upload dispersion factors as an Excel file (.xlsx) or comma seperated text file (.csv).", style="margin-botom:-20px; padding-bottom:0px;"), 
                uiOutput("disp_up"), hr())
         ),
                   
                   
tabPanel("Emissions", 
         # Collect emission information        
         h3("  Emissions"), hr(),
         # Pollutant Reference
         fluidRow(column(3, h4("Add pollutant: ", style="margin-top:13px; padding:0px; margin-right: 20px; padding-right: 0px; width: 100%; margin-bottom:0px;")), 
                  column(4, uiOutput("pollutants"), tags$head(tags$style(type="text/css", "#pollutants {margin:0px; margin-top: -16px; padding:0px; margin-left:-100px; width: 90%;"))), 
                  column(7)),
         
         tabsetPanel(          
         # Hourly emission rate 
         tabPanel("Hourly emissions",
           column(12, br(),
                p("Enter maximum hourly emissions in lbs/hr. Add additional pollutants on a new line."), 
                br(),
                dataTableOutput("hr_emissions_table"),
                hr(), 
                p("Optional: Upload hourly emissions as an Excel file (.xlsx) or comma separated text file (.csv).", style="margin-botom:-20px; padding-bottom:0px;"),
                uiOutput("hr_emissions_up"), hr())),
                       
          # Annual emission rate
          tabPanel("Annual emissions",
            column(8, br(),
                 p("Enter maximum annual emissions in tons/year. Add additional pollutants on a new line."),
                 br(),
                 dataTableOutput("ann_emissions_table"),
                 hr(),
                 p("Optional: Upload annual emissions as an Excel file (.xlsx) or comma seperated text file (.csv).", style="margin-botom:-20px; padding-bottom: 0px;"), 
                 uiOutput("ann_emissions_up"), hr()))
           )
         ),
              
              
tabPanel("Air concentrations", 
         # Show concentrations 
         h3("  Maximum air concentrations"), hr(),
         dataTableOutput("conc_table")
         ),
              
 
tabPanel("Risk summary", 
         # Show risk results 
         h3("  Risk summary"), hr(style="margin-top:0px;"), 
         tabsetPanel(
           
         tabPanel("Total facility risk", 
                  dataTableOutput("total_risk_table"),
                  hr(style="margin-top:5px;")
                  ),
         
         tabPanel("Pollutant specific risk", 
                  dataTableOutput("risk_table"),
                  hr(style="margin-top:5px;")
                  )
         )),

navbarMenu("About",
         tabPanel("Health benchmarks",
                  dataTableOutput("tox_table"),
                  hr(style="margin-top:5px;")
           ),
         
         tabPanel("Recent updates",
                  h3("  Updates:"),
                  hr(style="margin-top:5px;")
         ))
          

)      
)
