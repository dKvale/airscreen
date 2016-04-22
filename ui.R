# This is the user-interface of the Facilty emissions web application.
library(shiny)
library(leaflet)

helper_text <-  "* Select an Excel file (.xlsx) or comma separated text file (.csv)"

file_types <- c('.xlsx', '.xls', '.csv', 'text/.csv', 'text/csv')

shinyUI(navbarPage("Facility Air Screen", 
                   

tabPanel("Facility",
    fluidRow(column(12, h3("Facility information"), hr())),
    fluidRow(column(3, 
                    h4("Upload inputs"),
                    div(fileInput("master", label=NULL, width="95%", accept=c('.xlsx')),
                        style="margin-top:15px; margin-bottom:-5px")),
             column(3,
                    h4("Save results"),
                    div(downloadButton("download_inputs", 
                                       label = "Download risk summary", 
                                       class="down_btn"), 
                        style="margin-left:0; margin-top:0; margin-bottom:20px;"))
             ),
              
    fluidRow(column(5,
           p("Facility name (ID#)"),
           uiOutput('fac_name_UI'),
           p("Facility address"),
           uiOutput('address_UI'),
           p("Coordinates"),
           fluidRow(column(1), 
                    column(4, p("Lat", style="font-style: italic;")),
                    column(4, p("Long", style="font-style: italic;"))
                    ),
           fluidRow(column(1),
                    column(4, uiOutput('fac_lat_UI'), style="margin-left:-35px;"),
                    column(4, uiOutput('fac_long_UI'), style="margin-left:0;")
                    )
           ),
    column(5,
           p("Facility location"),
           leafletOutput("fac_map", height=340))
    )
),
                                      
tabPanel("Dispersion", 
         fluidRow(column(12, h3("Dispersion factors"), hr())),
         tabsetPanel(
         tabPanel("Stack parameters", br(),
         fluidRow(column(1), 
                  column(7, 
                         p("Upload stack height and fenceline distance in meters.", class='upload_text'),    
                         fileInput("stack_up", 
                                   label=NULL, 
                                   accept=file_types), 
                         p(helper_text, class = "help_text"),
                         class = 'upload_box')),
         
         fluidRow(column(11, h4("Stack parameters"),
                         p("All lengths in meters.", class='subtitle'),
         dataTableOutput('stack_table')))
),
        tabPanel("Unit dispersion", br(),
          fluidRow(column(1), 
                   column(7, 
                          p("Upload unit dispersion factors. When left blank dispersion 
                             factors will be generated based on each stack's height and fenceline 
                             distance.", class='upload_text'),    
                          fileInput("disp_up", 
                                    label=NULL,
                                    accept=file_types), 
                          p(helper_text, class = "help_text"),
                          class = 'upload_box')),
          fluidRow(column(11, 
                          h4("Unit dispersion factors"),
                          dataTableOutput("disp_table"))
                   )
          ))
),

tabPanel("Emissions",      
         fluidRow(column(12, h3("Emissions"), hr())),
         fluidRow(column(1),
                  column(7, 
                         p("Upload potential 1-hour emissions in lbs/hr and annual emission in tons/yr. 
                           Assume worst-case conditions for 1-hr emissions and
                           maximum operating capacity for annual emissions.", 
                           class="upload_text"), 
                         fileInput("emissions_up", 
                                   label=NULL, 
                                   accept=file_types), 
                         p(helper_text, class = "help_text"),
                         class='upload_box')),
         fluidRow(column(11, 
                         h4("Potential emissions by source"),
                         dataTableOutput("emissions_table"))
                  )
),

tabPanel("Air concentrations",          
         fluidRow(column(12, h3("Maximum air concentrations"), hr())),
         tabsetPanel(
           tabPanel("Total facility", br(), 
           fluidRow(column(1), 
                    column(7,
                           p("Optional: Upload maximum Aermod concentration results for all stacks combined.", 
                             class='upload_text'), 
                           fileInput("conc_up", label=NULL, accept=file_types), 
                           p(helper_text, class = 'help_text'),
                           class= "upload_box")),
           fluidRow(column(9, h4("Total facility air concentrations"),
           p("All concentrations shown in (ug/m3).", class='subtitle'),
           dataTableOutput("conc_table")))),

           tabPanel("Stack specific", br(),
             fluidRow(column(9, h4("Stack specific air concentrations"),
                    p("All concentrations shown in (ug/m3).", class='subtitle'),
                      dataTableOutput("st_conc_table"))))
           )
),

tabPanel("Risk summary", 
         fluidRow(column(12, h3("Risk summary"), hr())), 
         tabsetPanel(
            tabPanel("Total facility", br(),
                    fluidRow(column(11, h4("Inhalation results")),
                             column(11, dataTableOutput("total_air_risk_table"), br(), hr()),
                             column(11, h4("Multi-pathway results")),
                             column(11, dataTableOutput("total_media_risk_table")))
           ),
           
           tabPanel("Pollutant specific", br(), 
                    fluidRow(column(11, h4("Inhalation and multi-pathway results")),
                             column(11, div(dataTableOutput("pollutant_risk_table"), 
                                            style="font-size:86%;"),
                                    br(), hr()))
           ),
           
           tabPanel("Endpoint specific", br(), 
                    fluidRow(column(11, h4("Inhalation results by health endpoint")),
                      column(11, dataTableOutput("endpoint_risk_table")))
           ),
           
           tabPanel("Pollutants of concern", br(),
                    fluidRow(column(8, h4("Persistent bioaccumulative toxins (PBTs)"))),
                    fluidRow(column(1), column(5, dataTableOutput("pbt_table"))),
                    br(),
                    fluidRow(column(8, h4("Developmental pollutants with MDH ceiling values"))),
                    fluidRow(column(1), column(5, dataTableOutput("develop_table"))),
                    br(),
                    fluidRow(column(8, h4("Respiratory sensitizers"))),
                    fluidRow(column(1), column(5, dataTableOutput("sensitive_table")))
                    )
         )
),
           navbarMenu("More",
                      tabPanel("Inhalation health benchmarks",
                               fluidRow(column(12, h3("Health benchmarks"), hr())),
                               fluidRow(column(11, dataTableOutput("tox_table")))),
                               
                      tabPanel("Pollutant health endpoints",
                               fluidRow(column(12, h3("Health endpoints"), hr())),
                               fluidRow(column(11, dataTableOutput("endpoints")))),
                      
                      tabPanel("Multi-pathway risk factors",
                               fluidRow(column(12, h3("Multi-pathway risk factors"), hr())),
                               fluidRow(column(11, dataTableOutput("mpsf")))),

                      tabPanel("References",
                               fluidRow(column(12, h3("References"), hr())),
                               fluidRow(column(8, h4("Health benchmark hierarchy"))))
                      ),
br(), hr()
))
