# add tour guide to html file

index <- readLines("www/index.html")

add_css<- readLines(textConnection(
  '<link type = "text/css" rel = "stylesheet" href = "css/tour.css" />
  <link type = "text/css" rel = "stylesheet" href = "css/floaters.css" />
  <link type = "text/css" rel = "stylesheet" href = "css/font-awesome.min.css" />
  <link rel="stylesheet" type="text/css" href="bootstrap.min.css"/>
  <script src="shared/bootstrap/js/bootstrap.min.js"></script>

 <link href="https://fonts.googleapis.com/css?family=Open+Sans:400,700|Roboto+Condensed:400,700" rel="stylesheet" type="text/css" />
    
  '
))
index <- c(index[1:(grep("</head>", index)-1)], 
           add_css, 
           index[grep("</head>", index):length(index)])


add_tour <- readLines(textConnection('<!-- TOUR -->
   <div id = "tour" class = "tour" style = "display: none;">
      <div class = "tour-body">
        <div class = "header">Welcome to Fair Screen!</div>
        <div class = "content"></div>
        <div class = "tourCookie">
          <input type = "checkbox" id = "tourGone" />
          <label for = "tourGone">Hide this screen</label>
        </div>
        <button id = "tourNext" disabled = disabled>Next</button>
        <div class = "navigation">
          <a class = "close icon"><i class = "fa fa-close"></i></a>
        </div>
      </div>
      <div class = "tour-arrow-border"></div>
      <div class = "tour-arrow"></div>
    </div>  '))

index <- c(index[1:grep("</nav>", index)], 
           add_tour, 
           index[(grep("</nav>", index)+1):length(index)])

add_script <- '<script src = "js/tour.js"></script>'

index <- c(index[1:(grep("</html>", index)-1)], 
                add_script, 
                index[grep("</html>", index):length(index)])

writeLines(index, "www/index.html")
