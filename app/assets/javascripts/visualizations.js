var spin;

  $('.dropdown-menu').find('form').click(function (e) {
    e.stopPropagation();
  });

function start_spin(){
  spin = new Spinner().spin();
  document.getElementById("spinner").appendChild(spin.el);
}

function stop_spin(){
  spin.stop()
}

function vis1(){

  d3.json("/call?url=https://wwws.appfirst.com/api/servers/&", function(error, response){
    console.log(response)
    var data = [];
    data = response;

    var diameter = 700,
      format = d3.format(",d"),
      color = d3.scale.category20c();

    var bubble = d3.layout.pack()
      .sort(null)
      .size([diameter, diameter])
      .padding(1.5);

    var svg = d3.select("body").append("svg")
      .attr("width", diameter)
      .attr("height", diameter)
      .attr("class", "bubble");

    d3.json("", function(error, root){ //Method waits for Json to return before excuting visulaization code
      var node = svg.selectAll(".node")
        .data(bubble.nodes(classes(data)) //wily step. Create d.r, d.x and d.y
        .filter(function(d) { return !d.children; }))
        //MUST filter by child node. Otherwise you get one large node.
        .enter().append("g")
        .attr("class", "node")
        .attr("transform", function(d){ return "translate(" + d.x + "," + d.y + ")"; });

        node.append("title")
          .text(function(d) { return d.className + ": " + format(d.value); });

        //Creates the circles and places them in the DOM
        node.append("circle")
          .attr("r", function(d){ return d.r; })
          .style("fill", function(d){ return "rgb(0," + Math.round(d.r*2) + ",0)"; })
          .style("stroke", "darkgreen");

        node.append("text")
          .attr("dy", ".3em")
          .style("text-anchor", "middle")
          .text(function(d) { return d.className.substring(0, d.r / 3); }); 
      });
    
      //Returns flattened data
      //Extracts nickname of server and memory capacity which are then pushed into an array
      function classes(root){
        var classes = [];
        for(var i=0; i<root.length;i++){
          var obj = root[i];
          for(var key in obj){
            if(key == "nickname")
            var n = obj[key];
          if(key == "capacity_mem")
            var c = obj[key];
        }
        classes.push({packageName: name, className: n, value: c});
      }
      return {children: classes};
    }
  })
}

function vis2(response){
  d3.json("/call?url=https://wwws.appfirst.com/api/servers/", function(error, response){
    var data = [];
    data = response;
   
    var width = 960;
    var height = 1160;

    var projection = d3.geo.albers()
      .center([0, 55.4])
      .rotate([4.4, 0])
      .parallels([50, 60])
      .scale(1)
      .translate([width / 2, height / 2]);

    var path = d3.geo.path()
      .projection(projection);

    var svg = d3.select("body").append("svg")
      .attr("width", width)
      .attr("height", height);

    d3.json("us.json", function(error, us) {
      svg.append("path")
        .datum(topojson.feature(us, us.objects.subunits))
        .attr("d", path);
    });
  });
}

function vis3(id, name, attr){
  d3.json("/call?url=https://wwws.appfirst.com/api/servers/" + 
    id + "/data/?num=180", function(error, response){

      stop_spin();

      var data = [];
      data = response;

      var height = 230;
      var width = 1300;
      var margin = 1;

      var svg = d3.select(".svg_container").insert("svg", "svg")
        .attr("width", width)
        .attr("height", height);

      svg.append("text")
        .attr("x", $('svg').attr("width")/2)             
        .attr("y", $('svg').attr("height")-($('svg').attr("height")- 14))
        .attr("text-anchor", "middle")  
        .style("font-size", "18px") 
        .style("fill", "black")
        .text(name + attr);

      var xscale = d3.time.scale()
        .domain([new Date(date(data[0].time)), new Date(date(data[data.length - 1].time))])
        .range([0, width]);

      var test = "d." + attr
      var yscale = d3.scale.linear()
        .domain([d3.min(array(attr, data)) - margin, d3.max(array(attr, data)) + margin])
        .range([height, 0])

      var xaxis = d3.svg.axis()
        .orient("top")
        .scale(xscale);

      var yaxis = d3.svg.axis()
        .scale(yscale)
        .orient("right")
        .ticks(5)
        .tickSize(12);


      var line = d3.svg.line()
        .x(function(d){return xscale(date(d.time))})
        .y(function(d){return yscale(eval(test))})

      var tooltip = d3.select("body")
        .append("div")
        .attr("class", "tooltip")
        .style("opacity", -1);

      var node = svg.selectAll('node')
        .data(data)
        .enter()
        .append("circle")
        .attr("cx", function(d){return xscale(date(d.time))})
        .attr("cy", function(d){return yscale(eval(test))})
        .attr("r", 7)
        .on("mouseover", function(d){ 
          tooltip.text(attr + ": " + eval(test) +"\n\ndate: " + date(d.time))
            .transition()
            .duration(400)
            .style("opacity", 1)
            .style("left", (d3.event.pageX - 90) + "px")
            .style("top", (d3.event.pageY - 20) + "px");
        })
        .on("mouseout", function(d){
          tooltip.transition()
            .duration(200)
            .style("opacity", -1);
        });

      var path = svg.append("path")
        .attr("d", line(data));

      svg.append("g")
        .attr("class", "axis")
        .attr("transform", "translate(0," + height + ")")
        .call(xaxis);

      svg.append("g")
        .attr("class", "axis")
        .call(yaxis);
      });
}

function array(attr, data){
  var result = [];
  for (var i=0; i<data.length; i++){
    var obj = data[i];
    for(var key in obj){
      if(key == attr)
       result[i] = obj[key];
    }
  }
  return result;
}

function date(epochtime){
  var d = new Date(0); // The 0 there is the key, which sets the date to the epoch
  d.setUTCSeconds(epochtime);
  return d;
}