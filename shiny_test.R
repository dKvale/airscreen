library(shiny)
library(leaflet)

r_colors <- rgb(t(col2rgb(colors()) / 255))
names(r_colors) <- colors()

ui <- fluidPage(
  leafletOutput("mymap"),
  p(),
  actionButton("recalc", "New points"),
  uiOutput('fac_lat_UI'),
  uiOutput('fac_long_UI'),
  div(fileInput("master", label=NULL, width="220px", accept=c('.xlsx')),
      style="margin-left:0; padding-left:0;
      margin-top:20px; margin-bottom:0px")
)

server <- function(input, output, session) {
  coords <- read.csv(textConnection("lat,long
                                   46.29015, -96.063"))
  
  points <- eventReactive(input$recalc, {
    cbind(rnorm(40) * 2 + 13, rnorm(40) + 48)
  }, ignoreNULL = FALSE)
  
  output$fac_lat_UI <- renderUI({
    textInput('lat', label=NULL, placeholder='46.29', value = '46.29')
  })
  
  output$fac_long_UI <- renderUI({
    textInput('long', label=NULL, placeholder='-96.063', value='-96.063')
  })
  
  coords.new <- reactive({
    xy <- coords
    #invalidateLater(5000)
    if(!is.null(input$lat)) xy[1,1] <- as.numeric(input$lat)
    if(!is.null(input$long)) xy[1,2] <- as.numeric(input$long)
    xy
  })
  
  output$mymap <- renderLeaflet({
    xy <- points()
    
    if(!is.null(input$long)) xy <- coords.new()
    
    leaflet() %>%
      addProviderTiles("Stamen.TonerLite",
                       options = providerTileOptions(noWrap = TRUE)
      ) %>%
      addMarkers(data = xy)
  })
}

shinyApp(ui, server)