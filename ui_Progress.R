# This is the user-interface of the Facilty emissions web application.
library(shiny)

shinyUI(navbarPage("Facility Air Screen", theme = "bootstrap_readable.css",
          
                   
                   ,
                   
                   tabPanel("Pollutant specific risk", 
                            dataTableOutput("risk_table"),
                            hr(style="margin-top:5px;")
                   ),
                   
                   tabPanel("Source specific risk", 
                            dataTableOutput("risk_table"),
                            hr(style="margin-top:5px;")
                   )
                   
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
                                       dataTableOutput("tox_table"),
                                       hr(style="margin-top:5px;")
                              ),
                              tabPanel("Pollutant endpoints",
                                       dataTableOutput("tox_points"),
                                       hr(style="margin-top:5px;")
                              ),
                              
                              tabPanel("Recent updates",
                                       h3("  Updates:"),
                                       hr(style="margin-top:5px;")
                              ))
                   
                   
)      
)
