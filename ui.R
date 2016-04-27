# This is the user-interface of the Facilty emissions web application.
library(shiny)
library(leaflet)
library(DT)

shinyUI(navbarPage("Facility Air Screen", 
                   theme = 'css/fair-screen.css',
                  

tabPanel("Facility", tags$head(
  tags$link(rel = "stylesheet", type = "text/css", href = "css/font-awesome.min.css"),
  tags$link(rel = "stylesheet", type = "text/css", href = "css/tour.css")),
    
  fluidRow(column(12, h3("Facility information"), hr())),
    
  div(id = "tour", class = "tour", style = "display: none;",
    div(class = "tour-body",
    div(class = "header", "Welcome to Fair Screen!"),
    div(class = "content"),
    div(class = "tourCookie",
    tags$input(type = "checkbox", id = "tourGone"),
    tags$label("Don't show again")),
    tags$button(id = "tourNext", "Next"),
    div(class = "navigation"),
    a(class = "close icon", tags$i(class = "fa fa-close"))),
    div(class = "tour-arrow-border"),
    div(class = "tour-arrow")),
         
    fluidRow(column(4, 
                    h4("Upload inputs"), 
                    div(fileInput("master", label=NULL, width="220px", accept=c('.xlsx')),  id="file_central"),
                    style="margin-top:-5px;"),
             column(4,
                    h4("Save results"),
                    div(downloadButton("download_inputs", 
                                       label = "Download risk summary", 
                                       class="down_btn")),
                    style="margin-top:-5px;")),
           hr(),
    fluidRow(column(4,
           p("Facility name"),
           uiOutput('fac_name_UI'),
           p("Facility ID#"),
           uiOutput('fac_id_UI'),
           p("Coordinates"),
           fluidRow(column(4, p("Lat", style="font-style: italic; margin-left:5px;")),
                    column(5, p("Long", style="font-style: italic; margin-left:5px;"))
                    ),
           fluidRow(column(4, uiOutput('fac_lat_UI'), style="margin-left:0;"),
                    column(5, uiOutput('fac_long_UI'), style="margin-left:0;")
                    )
           ),
    column(6,
           p("Facility location"),
           leafletOutput('fac_map'))
    )
),
                                      
tabPanel("Dispersion", id='tour2',
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
                           Assume worst-case conditions and maximum operating capacity.", 
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

tabPanel("Concentrations",          
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

tabPanel("Risks", 
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
                               fluidRow(column(8, h4("Health benchmark hierarchy")))),
                     
                      tabPanel("Tour",
                               fluidRow(column(12, h3('Tour'), hr(),
                                               p('View an interactive tour of the app'),
                                               tags$button(id = "openTour", style = 'text-align: center;', "Open tour"),
                                               br()))
                               )
         ),
br(), hr(),
tags$script("var netAssess = {}"),
tags$script(src= "js/tour.js")
))
