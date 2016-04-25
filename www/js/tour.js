netAssess.tour = {slides: [], slideCount: 0, width: 450, height: 420, active: true}

netAssess.tour.makeSlide = function(options) {
  
  options = $.extend({
    position: "center",
    title: "NetAssess",
    text: "Welcome to Fair Screen!",
    target: "#welcomebox",
    runbefore: function() {},
    runafter: function() {}
  }, options)
  
  netAssess.tour.slides.push(options)
  
}

netAssess.tour.makeSlide({text: "<p>This tool provides risk estimates for potential facility air emissions.</p><p>First time users should begin by downloading the master template file and entering relevant facility and dispersion information.</p><div class='row'><div class='col-sm-1'></div><div class='col-sm-11 upload_box'><a href='https://github.com/dKvale/fair-screen/raw/master/data/Fair screen input template (MPCA).xlsx' class='btn' target='_blank'><i class='fa fa-download'></i> Download template file</a></div></div><p>When complete, click [Next] to continue this tour and learn how to upload your inputs.</p>"
})

netAssess.tour.makeSlide({title: "Menu bar",
                          text: "<p>Use the menu bar above to select individual inputs and review modeled risk results. </p><p>You can check 'Don`t show again' below to prevent the tour from opening next time. To view the tour again, select [Help] from the [More] section of the menu bar.</p>",
                          target: "#tour2",
                          position: "below"
                         
})


$(document).ready(function() {
  
  var name = "showtour"
  var showTour = "true";
  var ca = document.cookie.split(';');
  for(var i=0; i < ca.length; i++) {
    var c = ca[i];
    while (c.charAt(0)==' ') c = c.substring(1);
    if (c.indexOf(name) != -1) showTour = c.substring(name.length+1,c.length);
  }
  
  if(showTour == "true") {
    netAssess.tour.active = true;
    document.getElementById("tourGone").checked = false;
  } else {
    netAssess.tour.active = false;
    document.getElementById("tourGone").checked = true;
  }
  
  if(netAssess.tour.active) {
    netAssess.tour.advance()
  }
  
})

netAssess.tour.setPosition = function(target, position) {
  
  var rect = $(target)[0].getBoundingClientRect();
  
  var rect_center = {x: (rect.width / 2) + rect.left,
    y: (rect.height / 2) + rect.top
  }
  
  var arrowPos = {
    "left": "",
    "top": "",
    "display": "none",
    "border-left-color": "transparent",
    "border-top-color": "transparent",
    "border-right-color": "transparent",
    "border-bottom-color": "transparent"
  }
  
  switch(position) {
    case "center":
      var position = {
        top: rect_center.y - (netAssess.tour.height / 2),
        left: rect_center.x - (netAssess.tour.width / 2),
        display: "block"
      }
      arrowPos.top = "";
      arrowPos.left = "";
      arrowPos.display = "none";
      var arrowBorderPos = {};
      $.extend(arrowBorderPos, arrowPos);
      break;
      
      case "above":
        var position = {
          top: rect.top - (netAssess.tour.height + 15),
          left: rect_center.x - (netAssess.tour.width / 2),
          display: "block"
        };
      arrowPos.top = netAssess.tour.height - 5;
      arrowPos.left = netAssess.tour.width / 2;
      arrowPos.display = "block";
      arrowPos["border-top-color"] = "#EFEFEF";
      var arrowBorderPos = {};
      $.extend(arrowBorderPos, arrowPos);
      arrowBorderPos.top = arrowBorderPos.top + 2.5
      arrowBorderPos["border-top-color"] = "black";
      break;
      
      case "below":
        var position = {
          top: rect.bottom + 15,
          left: rect_center.x - (netAssess.tour.width / 2),
          display: "block"
        };
      arrowPos.top = -20;
      arrowPos.left = (netAssess.tour.width / 2) - 10;
      arrowPos.display = "block";
      arrowPos["border-bottom-color"] = "#B2CBD7";
      var arrowBorderPos = {};
      $.extend(arrowBorderPos, arrowPos);
      arrowBorderPos.top = arrowBorderPos.top - 2.5
      arrowBorderPos["border-bottom-color"] = "black";
      break;
      
      case "left":
        var position = {
          top: rect_center.y - (netAssess.tour.height / 2),
          left: rect.left - (netAssess.tour.width + 15),
          display: "block"
        }
      arrowPos.top = (netAssess.tour.height / 2) - 10;
      arrowPos.left = netAssess.tour.width - 5;
      arrowPos.display = "block";
      arrowPos["border-left-color"] = "#EFEFEF";
      var arrowBorderPos = {};
      $.extend(arrowBorderPos, arrowPos);
      arrowBorderPos.left = arrowBorderPos.left + 2.5;
      arrowBorderPos["border-left-color"] = "black";
      break;
      
      case "right":
        var position = {
          top: rect_center.y - (netAssess.tour.height / 2),
          left: rect.right + 15,
          display: "block"
        }
      arrowPos.top = (netAssess.tour.height / 2) - 10;
      arrowPos.left = -20;
      arrowPos.display = "block";
      arrowPos["border-right-color"] = "#EFEFEF";
      var arrowBorderPos = {};
      $.extend(arrowBorderPos, arrowPos);
      arrowBorderPos.left = arrowBorderPos.left - 2.5;
      arrowBorderPos["border-right-color"] = "black";
      break;
      
      default:
        console.log("Unrecognized 'position' to setPosition function.")
  }
  
  var w = window.innerWidth;
  var h = window.innerHeight;
  
  if(position.left < 0) {
    var offset_x = 5 + (position.left + netAssess.tour.width);
  } else if((position.left + netAssess.tour.width) > w) {
    var offset_x = 5 + ((position.left + netAssess.tour.width) - w);
  } else {
    var offset_x = 0;
  }
  
  position.left = parseInt(position.left - offset_x, 10) + "px";
  arrowPos.left = parseInt(arrowPos.left + offset_x, 10) + "px";
  arrowBorderPos.left = parseInt(arrowBorderPos.left + offset_x, 10) + "px";
  
  if(position.top < 0) {
    var offset_y = 5 - position.top; 
  } else if((position.top + netAssess.tour.height) > h) {
    var offset_y = (position.top + netAssess.tour.height) - h;
  } else {
    var offset_y = 0;
  }
  
  position.top = parseInt(position.top + offset_y, 10) + "px";
  arrowPos.top = parseInt(arrowPos.top - offset_y, 10) + "px";
  arrowBorderPos.top = parseInt(arrowBorderPos.top - offset_y, 10) + "px";
  
  var $tour = $("#tour");
  $tour.css(position);
  $tour.find(".tour-arrow").css(arrowPos);
  $tour.find(".tour-arrow-border").css(arrowBorderPos);
  
}

netAssess.tour.advance = function() {
  
  var tour = netAssess.tour;
  var $tour = $("#tour");
  
  var cnt = tour.slideCount;
  
  if(cnt > 0) tour.slides[cnt - 1].runafter();
  tour.slides[cnt].runbefore();
  
  $tour.find(".header").html(tour.slides[cnt].title);
  $tour.find(".content")[0].scrollTop = 0;
  $tour.find(".content").html(tour.slides[cnt].text);
  tour.setPosition(tour.slides[cnt].target, tour.slides[cnt].position);
  
  
  
  tour.slideCount++
    
}

netAssess.tour.close = function() {
  netAssess.tour.active = false;
  $("#tour").css("display", "none")
  $("*").off(".tour");
}

$("#tourNext").on("click", function() {
  
  if(netAssess.tour.slideCount == netAssess.tour.slides.length - 1) {
    $("#tourNext").text("Close")
  } else {
    $("#tourNext").text("Next")
  }
  if(netAssess.tour.slideCount == netAssess.tour.slides.length) {
    netAssess.tour.close()
  } else {
    netAssess.tour.advance()
  }
  
})

$("#tour .close").on("click", netAssess.tour.close);

$("#tour #tourGone").on("click", function(e) {
  var d = new Date();
  d.setTime(d.getTime() + (60*24*60*60*1000));
  var expires = "expires="+d.toUTCString();
  
  if(this.checked) {
    document.cookie = "showtour=false; " + expires
  } else {
    document.cookie = "showtour=true; " + expires
  }
  
})

$("#openTour").on("click", function() {
  if(netAssess.tour.active == false) {
    netAssess.tour.slideCount = 0;
    netAssess.tour.active = true;
    netAssess.tour.advance();
    netAssess.sidebars.help.hide();
  }
})

// Disabled the Next button until the page has a chance to load to avoid the 
// user clicking too early.
$("#tourNext").attr("disabled", true);
$(document).ready(function() {
  setTimeout(function() {$("#tourNext").attr("disabled", false)}, 1000)
})  
