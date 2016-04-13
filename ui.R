# This is the user-interface of the Facilty emissions web application.
library(shiny)

shinyUI(navbarPage("Facility Air Screen", 
                   theme = "bootstrap_custom.css", 

tabPanel("Home", 
    h3("    Facility information"), hr(),
    column(4,
           p("Facility name"),
           textInput('facility', label=NULL, placeholder='Murphy`s Vaccuum Cleaners'),
           p("Facility address"),
           textInput('address', label=NULL, placeholder='431 Broom St. North, Murphy Town'),
           p("Coordinates"),
           fluidRow(column(1), column(5, p("Lat", style="font-style: italic;")),
                    column(5, p("Long", style="font-style: italic;"))),
           fluidRow(column(1), 
                    column(5, textInput('lat', label=NULL, placeholder='46.29')),
                    column(5, textInput('long', label=NULL, placeholder='-96.063'))),
           p("Upload facility input file"),
           uiOutput('inputs_up'),
           p("See example input file", style="margin-top:-25px; margin-bottom:5px;"),
           actionButton("add_btn", "View input template", icon("download")),
           br(), br()
           #p("Pollutant reference"),
           #uiOutput("pollutants")
           ),
    
    column(6,
           p(" Facility location"),
           leafletOutput("fac_map")), hr()
    ),
                                      
tabPanel("Dispersion", 
         h3("    Dispersion factors"), hr(),
         tabsetPanel(
         tabPanel("Stack parameters",
         column(8, h4("Upload stack height and fenceline distance", style="margin-botom:0px; padding-bottom:0px;"), 
                p("Select units"), 
                selectizeInput('st_units', label=NULL, choices=c("Feet", "Meters"), selected="Feet"), 
                p("Select an Excel file (.xlsx) or comma separated text file (.csv)."), 
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
         fluidRow(column(9, p("Upload potential 1-hour emissions in lbs/hr and annual emission in tons/yr. 
                              Assume startup and worst-case fuel conditions for 1-hr emissions. Assume maximum capacity for annual emissions.", style="font-style: italic;"))), 
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
                    column(9, p("  All concentrations shown in (ug/m3).", style="font-style: italic; font-size: 1.1em;"),
                           dataTableOutput("conc_table"))),
           tabPanel("Stack specific", br(),
             column(9, p("  All concentrations shown in (ug/m3).", style="font-style: italic; font-size: 1.1em;"),
             dataTableOutput("st_conc_table"))))
),

tabPanel("Risk summary", 
         # Show risk results 
         h3("    Risk summary"), hr(), 
         tabsetPanel(
           
           tabPanel("Total facility", br(), br(), 
                    fluidRow(column(11, 
                                    h4("Inhalation only risk table", style="font-style: italic; font-size: 1.1em;"),
                                    dataTableOutput("total_air_risk_table"),
                                    hr(), br(), 
                                    p("Multi-media longterm risk table", style="font-style: italic; font-size: 1.1em;"),
                                    dataTableOutput("total_media_risk_table"),
                                    hr()))
           ),
           
           tabPanel("Pollutant specific", br(), br(), 
                    fluidRow(column(11, 
                                    h4("Inhalation only risk table", style="color: grey;"),
                                    dataTableOutput("air_risk_table"),
                                    hr(), br(),
                                    h4("Multi-media longterm risk table", style="color: grey;"),
                                    dataTableOutput("media_risk_table"),
                                    hr()))
           ),
           
           tabPanel("Risk by health endpoint", br(), br(),
                    fluidRow(column(11, 
                    dataTableOutput("endpoint_risk_table"),
                    hr(style="margin-top:5px;")))
           ),
           
           tabPanel("Pollutants of concern", br(), br(),
                    fluidRow(column(11, 
                    h4("Persistent Bioaccumulative Toxicants", style="color: grey;"), dataTableOutput("pbts"),
                    br(),
                    h4("Developmental toxicants with MDH ceiling values", style="color: grey;"),
                    hr()))
           ))),
           
           tabPanel("Save",
                    h3("    Save risk summary"),
                    fluidRow(
                      column(4, textInput('Fname', label=NULL, placeholder='Enter file name: "Risk Summary 2016"')),
                      column(3, downloadButton("download", label = "   Download risk summary", class="down_btn"))),
                    hr(),
                    
                    h3("    Save inputs"),
                    fluidRow(
                      column(4, textInput('Fname2', label=NULL, placeholder='Enter file name: "RASS Inputs 2016"')),
                      column(3, downloadButton("download_inputs", label = "   Download facility inputs", class = "down_btn"))),
                    hr()),
           
           navbarMenu("More",
                      tabPanel("Health benchmarks",
                               fluidRow(column(11, dataTableOutput("tox_table"),
                               hr(style="margin-top:5px;")))
                      ),
                      
                      tabPanel("Pollutant endpoints",
                               fluidRow(column(11,
                                      dataTableOutput("endpoints"),
                               hr(style="margin-top:5px;")))
                      ),
                      
                      tabPanel("Recent updates",
                               h3("  Updates:"),
                               hr(style="margin-top:5px;")
                      ))
)      
)
