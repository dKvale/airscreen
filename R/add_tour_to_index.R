# add tour guide to html file

index <- readLines("www/index.html")

add_css <- readLines(textConnection(
  '\n
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>  
  <script type="application/shiny-singletons"></script>  
  <script type="application/html-dependencies">json2[2014.02.04];jquery[2.2.1];shiny[0.13.2];font-awesome[4.5.0];htmlwidgets[0.6];leaflet[0.7.3];leafletfix[1.0.0];leaflet-binding[1.0.1];datatables-binding[0.1.55];bootstrap[3.3.5]</script>
  
  <script src="shared/jquery.js" type="text/javascript"></script>
  <script src="shared/shiny.js" type="text/javascript"></script>
  
  <script src="shared/json2-min.js"></script>
  
  <link href="shared/shiny.css" rel="stylesheet" />
  
  <link href="shared/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
  <script src="htmlwidgets-0.6/htmlwidgets.js"></script>
  
  <script src="datatables-binding-0.1.55/datatables.js"></script>
  
  
  <link href="shared/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
  <script src="shared/bootstrap/js/bootstrap.min.js"></script>
  <script src="shared/bootstrap/shim/html5shiv.min.js"></script>
  
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  
  <link href="leaflet-0.7.3/leaflet.css" rel="stylesheet" />
  <script src="leaflet-0.7.3/leaflet.js"></script>
  <link href="leafletfix-1.0.0/leafletfix.css" rel="stylesheet" />
  <script src="leaflet-binding-1.0.1/leaflet.js"></script>
  <script src="shared/bootstrap/shim/respond.min.js"></script> 
  <title>Facility Air Screen</title>
  
  <link type="text/css" rel="stylesheet" href="css/font-awesome.min.css" />
  
  <link type="text/css" rel="stylesheet" href="css/tour.css" />
  
  <link type="text/css" rel="stylesheet" href="css/fair-screen.css" /> 
  \n
  '
))

index <- c(index[1:grep("<head>", index)[1]], 
           add_css, 
           index[grep("</head>", index):length(index)]
           )

# Add tour IDs
#add_tour_id2 <- "tour2"

#index <- c(index[1:(grep('data-value="Dispersion"', index)[1]-2)],
#          '<li id="tour2">',
#           index[grep('data-value="Dispersion"', index)[1]:length(index)])

# Add tour DIV()
add_tour <- readLines(textConnection('<!-- TOUR -->
   <div id = "tour" class = "tour" style = "display: none;">
      <div class = "tour-body">
        <div class = "header">Welcome to Fair Screen!</div>
        <div class = "content"></div>
        <div class = "tourCookie">
          <input type = "checkbox" id = "tourGone" />
          <label for = "tourGone">Don`t show again</label>
        </div>
        <button id = "tourNext">Next</button>
        <div class = "navigation">
          <a class = "close icon"><i class = "fa fa-close"></i></a>
        </div>
      </div>
      <div class = "tour-arrow-border"></div>
      <div class = "tour-arrow"></div>
    </div>  '))

index <- c(index[1:(grep("</nav>", index)+4)], 
           add_tour, 
           index[(grep("</nav>", index)+5):length(index)])

index[grepl("Don`t", index)] <-  "          <label for = \"tourGone\">Don't show again</label>"

index[grepl("Don't", index)]

add_script <- 
'
<script>var netAssess = {}</script>
<script src = "js/tour.js"></script>
'

index <- c(index[1:grep("</body>", index)],
           add_script,
           "</html>")

writeLines(index, "www/index.html")
