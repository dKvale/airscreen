# This is the user-interface of the Facilty emissions web application.
library(shiny)
library(leaflet)

helper_text <-  "Select an Excel file (.xlsx, .xls) or comma separated text file (.csv)"

file_types <- c('.xlsx', '.xls', '.csv', 'text/.csv', 'text/csv')

shinyUI(navbarPage("Facility Air Screen", 
                   theme = "bootstrap_custom.css", 

tabPanel("Welcome",
        fluidRow(column(12, h3("Welcome!"), hr())),
        fluidRow(column(8, h4("First time users"),
         p("Begin by downloading the master template file below and entering the relevant facility and dispersion
           parameters. 
           When complete, move on to the next step to upload your inputs.
           Alternatively, the menu above may be used to upload inputs individually."))),
        fluidRow(column(1), 
                 column(6,
                        p("Download the master input template.", class = 'upload_text'),
                        a(href = 'https://github.com/dKvale/fair-screen/raw/master/data/fair_screen_template.xlsx',
                          class = "btn", 
                          icon("download"), 
                          target="_blank", 
                          'Download templates'), class = 'upload_box')),
        br(),
        fluidRow(column(8, h4("Upload inputs"), hr(),
         p("Use the window below to upload a facility's inputs as
           a multi-tabbed Excel file."))),
        fluidRow(column(1), 
                 column(6, 
                        p("Select a master input Excel (.xlsx) file.", class='upload_text'),    
                        div(fileInput("inputs_up", label=NULL, accept=c('.xlsx')), 
                            style="margin-bottom:-15px;"),
                        class = 'upload_box')),
        br(),
        fluidRow(column(8, h4("Save results"), hr(),
        p("Save the facility's risk screening results as an Excel file 
          to be included with the modeling protocol submission."))),
        fluidRow(column(1), 
                 column(6, 
                        p('Download the risk summary file.', class='upload_text'),
                        #textInput('Fname', label=NULL,  placeholder='"Risk Summary 2016-04-22.xlsx"'),
                        downloadButton("download_risk", 
                                       label = "Download risk summary", 
                                       class="down_btn"), 
                        class = 'upload_box'))
        ),
        
tabPanel("Facility",
    fluidRow(column(12, h3("Facility information"), hr())),
    fluidRow(column(4,
           p("Facility name (ID#)"),
           textInput('facility', label=NULL, placeholder='Murphy`s Vaccuum Cleaners (#457142)'),
           p("Facility address"),
           textInput('address', label=NULL, placeholder='431 Broom St. North, Murphy Town'),
           p("Coordinates"),
           fluidRow(column(1), 
                    column(4, p("Lat", style="font-style: italic;")),
                    column(4, p("Long", style="font-style: italic;"))
                    ),
           fluidRow(column(1),
                    column(4, textInput('lat', label=NULL, placeholder='46.29'), style="margin-left:-35px;"),
                    column(4, textInput('long', label=NULL, placeholder='-96.063'), style="margin-left:0;")
                    ),
           br()),
    column(6,
           p("Facility location"),
           leafletOutput("fac_map")))
),
                                      
tabPanel("Dispersion", 
         fluidRow(column(12, h3("Dispersion factors"), hr())),
         tabsetPanel(
         tabPanel("Stack parameters", br(),
         fluidRow(column(1), 
                  column(7, 
                         p("Upload stack height and fenceline distance.", class='upload_text'),    
                         fileInput("stack_up", 
                                   label=NULL, 
                                   accept=file_types), 
                         p(helper_text, class = "help_text"),
                         class = 'upload_box')),
         fluidRow(column(8, 
                  p("Select units", style="margin-top:8px;"), 
                  selectizeInput('st_units', label=NULL, choices=c("Feet", "Meters"), selected="Feet"))),
         fluidRow(column(11, h4("Stack parameters"),
         dataTableOutput('stack_table')))
),
        tabPanel("Unit dispersion", br(),
          fluidRow(column(1), 
                   column(7, 
                          p("Upload unit dispersion factors. If left blank, default dispersion 
                             factors are generated based on each stack's height and fenceline 
                             distance.", class='upload_text'),    
                          fileInput("disp_up", 
                                    label=NULL, 
                                    accept=file_types), 
                          p(helper_text, class = "help_text"),
                          class = 'upload_box')),
          fluidRow(column(11, h4("Unit dispersion factors"),
                   dataTableOutput("disp_table")))
          ))
),

tabPanel("Emissions",      
         fluidRow(column(12, h3("Emissions"), hr())),
         fluidRow(column(1),
                  column(7, 
                         p("Upload potential 1-hour emissions in lbs/hr and annual emission in tons/yr. 
                            Assume startup and worst-case fuel conditions for 1-hr emissions. 
                            Maximum operating capacity should be assumed for the calculation of annual emissions.", 
                           class="upload_text"), 
                         fileInput("emissions_up", 
                                   label=NULL, 
                                   accept=file_types), 
                         p(helper_text, class = "help_text"),
                         class='upload_box')),
         fluidRow(column(11, h4("Potential emissions by source"),
                dataTableOutput("emissions_table")))
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
                    fluidRow(column(11, h4("Inhalation only risk")),
                             column(11, dataTableOutput("total_air_risk_table"), br(), hr()),
                             column(11, h4("Multi-media risk")),
                             column(11, dataTableOutput("total_media_risk_table")))
           ),
           
           tabPanel("Pollutant specific", br(), 
                    fluidRow(column(11, h4("Inhalation only risk")),
                             column(11, dataTableOutput("air_risk_table"), br(), hr()),
                             column(11, h4("Multi-media risk")),
                             column(11, dataTableOutput("media_risk_table")))
           ),
           
           tabPanel("Risk by health endpoint", br(), 
                    fluidRow(column(11, h4("Inhalation risk by health endpoint")),
                      column(11, dataTableOutput("endpoint_risk_table")))
           ),
           
           tabPanel("Pollutants of concern", br(),
                    fluidRow(column(11, 
                    h4("Persistent bioaccumulative toxins (PBTs)"),
                    dataTableOutput("pbt_table"),
                    br(),
                    h4("Developmental pollutants with MDH ceiling values"),
                    dataTableOutput("develop_table"),
                    br(),
                    h4("Respiratory sensitizers"),
                    dataTableOutput("sensitive_table")
                    ))
          ))
),
           
           navbarMenu("More",
                      tabPanel("Health benchmarks",
                               fluidRow(column(12, h3("Health benchmarks"), hr())),
                               fluidRow(column(11, dataTableOutput("tox_table")))),
                               
                      tabPanel("Pollutant endpoints",
                               fluidRow(column(12, h3("Pollutant health endpoints"), hr())),
                               fluidRow(column(11,
                                      dataTableOutput("endpoints")))),
                      
                      tabPanel("Recent updates",
                               fluidRow(column(12, h3("Updates"), hr())))
                      ),
br(), hr())      
)
