# This is the user-interface of the Facilty emissions web application.
library(shiny)

shinyUI(navbarPage("Facility Air Screen", theme = "bootstrap_readable.css",

tabPanel("Home", 
    h3("    Facility Information"), hr(),
    column(8,
           p("Facility name"),
           textInput('facility', label=NULL, placeholder='Murphy`s Vaccuum Cleaners'),
           p("Facility address"),
           textInput('address', label=NULL, placeholder='431 Broom St. North, Murphy Town'),
           p("Lat/Long coordinates"),
           textInput('coords', label=NULL, placeholder='46.34, -96.21'),
           
           hr())
    ),
                                      
tabPanel("Dispersion", 
         h3("    Dispersion factors"), hr(),
         tabsetPanel(
         tabPanel("Stack parameters",
         column(8, h4("Upload stack height and fenceline distance", style="margin-botom:0px; padding-bottom:0px;"), 
                p("Select units"), 
                selectizeInput('st_units', label=NULL, choices=c("Feet", "Meters"), selected="Feet"), 
                p("Select an Excel file (.xlsx) or comma separated text file (.csv).", style="margin-botom:-40px; padding-bottom:-10px;"), 
                uiOutput('stack_up'),
                dataTableOutput('stack_table'))
),
        tabPanel("Unit dispersion", 
        # Collect dispersion factors
         column(8, h4("Upload unit dispersion factors", style="margin-botom:0px; padding-bottom:0px;"), 
                p("If left blank default dispersion factors are generated based on a stack's height and fenceline distance.", style="font-style: italic;"), 
                p("Select an Excel file (.xlsx) or comma separated text file (.csv).", style="margin-botom:-40px; padding-bottom:-10px;"), 
                uiOutput("disp_up"),
                dataTableOutput("disp_table"))
))),

tabPanel("Emissions",
         # Collect emission information        
         h3("    Emissions"), hr(),
         # Pollutant Reference
         fluidRow(
         column(5, uiOutput("pollutants")),
         column(3, actionButton("add_btn", " Add pollutant ", icon("plus")))), 
         br(),
         fluidRow(column(9, p("Upload potential 1-hour emissions in lbs/hr and annual emission in tons/yr. Assume startup and worst-case fuel conditions for 1-hr emissions. Assume maximum capacity for annual emissions.", style="font-style: italic;"))), 
         p("Select an Excel file (.xlsx) or comma separated text file (.csv).", style="margin-botom:-40px; padding-bottom:0px;"),
         uiOutput("emissions_up"), 
         dataTableOutput("emissions_table"),
         hr()
),

tabPanel("Air concentrations", 
         # Show concentrations 
         h3("    Maximum air concentrations"), hr(),
         tabsetPanel(
           tabPanel("Facility combined", br(),
                    column(9, p("  All concentrations shown in (ug/m3).", style="font-style: italic;"),
                           dataTableOutput("conc_table"))),
           tabPanel("Stack specific", br(),
             column(9, p("  All concentrations shown in (ug/m3).", style="font-style: italic;"),
             dataTableOutput("st_conc_table"))))
),

tabPanel("Risk summary", 
         # Show risk results 
         h3("    Risk summary"), hr(style="margin-top:0px;"), 
         tabsetPanel(
           
           tabPanel("Total facility risk", 
                    dataTableOutput("total_risk_table"),
                    hr()
           )
         ))
          
)      
)
