# This is the user-interface of the Facilty emissions web application.
library(shiny)
library(leaflet)

helper_text <-  "Select an Excel file (.xlsx, .xls) or a comma separated text file (.csv)"


shinyUI(navbarPage("Facility Air Screen", 
                   theme = "bootstrap_custom.css", 

tabPanel("Facility",
    fluidRow(column(12, h3("Facility information"), hr())),
    fluidRow(column(4,
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
           p("Upload stack, emissions and dispersion inputs", style="margin-top:5px;"),
           fluidRow(column(1), column(10, fileInput("inputs_up", label=NULL))), 
           #p("See example input file", style="margin-top:-25px; margin-bottom:5px;"),
           a(href = 'https://github.com/dKvale/fair-screen/raw/master/data/fair_screen_template.xlsx',
                  class = "btn", icon("download"),
                  style="margin-top:-20px;", 
                  target="_blank", ' Download input templates'),
           br(), br()
           ),
    fluidRow(column(6,
           p("Facility location"),
           leafletOutput("fac_map")), hr())
    )),
                                      
tabPanel("Dispersion", 
         fluidRow(column(12, h3("Dispersion factors"), hr())),
         tabsetPanel(
         tabPanel("Stack parameters",
         fluidRow(
           column(8, h4("Upload stack height and fenceline distance", style="margin-botom:0px; padding-bottom:0px;"), 
                p("Select units"), 
                selectizeInput('st_units', label=NULL, choices=c("Feet", "Meters"), selected="Feet"))),
         fluidRow(column(1), column(4, fileInput("stack_up", label=NULL))),
         fluidRow(column(1), column(7,
                p(helper_text, style="margin-top: -22px; padding-top:0; padding-bottom:10px; font-style: italic;"))),
                dataTableOutput('stack_table')
),
        tabPanel("Unit dispersion", 
          fluidRow(
                column(8, h4("Upload unit dispersion factors", style="margin-botom:0px; padding-bottom:0px;"), 
                p("If left blank, default dispersion factors are generated based on a stack's height and fenceline distance.", style="font-style: italic;"))), 
                fluidRow(column(11, fluidRow(column(1), column(8, fileInput("disp_up", label=NULL))),
                fluidRow(column(1), column(8,
                p(helper_text, style="margin-top: -22px; padding-top:0; padding-bottom:10px; font-style: italic;"))))),
                column(11, dataTableOutput("disp_table")))
)),

tabPanel("Emissions",      
         fluidRow(column(12, h3("Emissions"), hr())),
         fluidRow(column(9, p("Upload potential 1-hour emissions in lbs/hr and annual emission in tons/yr. 
                              Assume startup and worst-case fuel conditions for 1-hr emissions. Assume maximum capacity for annual emissions.", style="font-style: italic;"))), 
         uiOutput("emissions_up", style="margin-left: 30px"), p(helper_text, style="margin-top: -22px; margin-left:31px; padding-top:0; padding-bottom:10px; font-style: italic;"),
         dataTableOutput("emissions_table"),
         hr()
),

tabPanel("Air concentrations",          
         fluidRow(column(12, h3("Maximum air concentrations"), hr())),
         tabsetPanel(
           tabPanel("Total facility", br(),
           fluidRow(div(
             column(6, p("Optional: Upload maximum Aermod concentration results for the total facilty.", style="font-style: italic; margin-bottom: -10px"), 
             uiOutput("conc_up"), 
             p(helper_text, style="margin-top: -22px; margin-left:31px; padding-top:0; padding-bottom:10px; font-style: italic;"),
             style="border: 1px dotted; margin-left:15px; padding-left: 15px; padding-top:15px; margin-top:-15px; margin-bottom:5px;")
             )),
           
           h4("Total facility air concentrations"),
           p("All concentrations shown in (ug/m3).", style="font-style: italic; font-size: 1em;"),
           dataTableOutput("conc_table")),

           tabPanel("Stack specific", br(),
             column(9, h4("Stack specific air concentrations"),
                    p("All concentrations shown in (ug/m3).", style="font-style: italic; font-size: 1em;"),
                    dataTableOutput("st_conc_table")
                    
                    )))
),

tabPanel("Risk summary", 
         fluidRow(column(12, h3("Risk summary"), hr())), 
         tabsetPanel(
           
           tabPanel("Total facility", br(),
                    fluidRow(column(11, h4("Inhalation only risk")),
                             column(11, dataTableOutput("total_air_risk_table"),  hr(), br()),
                             column(11, h4("Multi-media risk")),
                             column(11, dataTableOutput("total_media_risk_table"), hr()))
           ),
           
           tabPanel("Pollutant specific", br(), 
                    fluidRow(column(11, h4("Inhalation only risk")),
                             column(11, dataTableOutput("air_risk_table"), hr(), br()),
                             column(11, h4("Multi-media risk")),
                             column(11, dataTableOutput("media_risk_table"), hr()))
           ),
           
           tabPanel("Risk by health endpoint", br(), 
                    fluidRow(column(11, h4("Inhalation risk by health endpoint")),
                      column(11, dataTableOutput("endpoint_risk_table"),
                    hr()))
           ),
           
           tabPanel("Pollutants of concern", br(),
                    fluidRow(column(11, 
                    h4("Persistent bioaccumulative toxins (PBTs)"),
                    dataTableOutput("pbt_table"),
                    br(),
                    h4("Developmental pollutants with MDH ceiling values"),
                    #hr(),
                    dataTableOutput("develop_table"),
                    br(),
                    h4("Respiratory sensitizers"),
                    #hr(),
                    dataTableOutput("sensitive_table")))
           ))),
           
           tabPanel("Save",
                    fluidRow(column(12, h3("Save risk summary"), hr())),
                    fluidRow(
                      column(4, textInput('Fname', label=NULL, placeholder='Enter file name: "Risk Summary 2016"')),
                      column(3, downloadButton("download_risk", label = "Download risk summary", class="down_btn"))),
                    hr(),
                    
                    h3("Save inputs"),
                    fluidRow(
                      column(4, textInput('Fname2', label=NULL, placeholder='Enter file name: "RASS Inputs 2016"')),
                      column(3, downloadButton("download_inputs", label = "Download facility inputs", class = "down_btn"))),
                    hr()),
           
           navbarMenu("More",
                      tabPanel("Health benchmarks",
                               fluidRow(column(12, h3("Health benchmarks"), hr())),
                               fluidRow(column(11, dataTableOutput("tox_table"),
                               hr(style="margin-top:5px;")))
                      ),
                      
                      tabPanel("Pollutant endpoints",
                               fluidRow(column(12, h3("Pollutant health endpoints"), hr())),
                               fluidRow(column(11,
                                      dataTableOutput("endpoints"),
                               hr(style="margin-top:5px;")))
                      ),
                      
                      tabPanel("Recent updates",
                               fluidRow(column(12, h3("Updates"), hr()))
                      ))
)      
)
