# add tour guide to html file

index <- readLines("www/index.html")

add_css <- readLines(textConnection(
  '<script src="shared/jquery.js" type="text/javascript"></script>
   <script src="shared/shiny.js" type="text/javascript"></script>
   <link type="text/css" rel="stylesheet" href="css/tour.css" />
   <link type="text/css" rel="stylesheet" href="css/floaters.css" />
   <link type="text/css" rel="stylesheet" href="css/font-awesome.min.css" />
   <link type="text/css" rel="stylesheet" href="css/fair-screen.css" />
  '
))

add_css <- readLines(textConnection('

   <link type="text/css" rel="stylesheet" href="css/tour.css" />

   <link type="text/css" rel="stylesheet" href="css/fair-screen.css" />
  '
))

index <- c(index[1:(grep("fair-screen.css", index)-1)], 
           add_css, 
           index[(grep("fair-screen.css", index)+1):length(index)]
           )

# Add tour IDs
add_tour_id21 <- "welcomebox"

#index <- c(index[1:(grep('data-value="Facility"', index)[1]-1)],
#                 '<li id="welcomebox">',
#                 index[grep('data-value="Facility"', index)[1]:length(index)])

add_tour_id2 <- "tour2"

index <- c(index[1:(grep('data-value="Dispersion"', index)[1]-2)],
          '<li id="tour2">',
           index[grep('data-value="Dispersion"', index)[1]:length(index)])

add_tour <- readLines(textConnection('<!-- TOUR -->
   <div id = "tour" class = "tour" style = "top: 240px; left:140px; display: block;">
      <div class = "tour-body">
        <div class = "header">Welcome to Fair Screen!</div>
        <div class = "content"></div>
        <div class = "tourCookie">
          <input type = "checkbox" id = "tourNext" />
          <label for = "tourGone">Don`t show again</label>
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

add_script <- 
'<script>var netAssess = {}</script>
 <script src = "js/tour.js"></script>'

index <- c(index[1:(grep("</html>", index)-1)], 
                add_script, 
                index[grep("</html>", index):length(index)])

writeLines(index, "www/index.html")
