function vis1(){

  var data = [];
  var req = $.ajax({
    url: '/call',
    type: 'post',
    data: 'url=' + "https://wwws.appfirst.com/api/servers/",
    success: function(response){
      data = response;
    }
  });

  $.when(req).done(function(){

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
      .style("fill", function(d){ return "rgb(0," + Math.round(d.r*2) + ",0)"; });

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
  });
}

function vis2(){
  var data = [];
  var req = $.ajax({
    url: '/call',
    type: 'post',
    data: 'url=' + "https://wwws.appfirst.com/api/servers/",
    success: function(response){
      data = response;
    }
  });

  $.when(req).done(function(){

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

function vis3(){
  var data = []
  var req = $.ajax({
    url: '/call',
    type: 'post',
    data: 'url=' + "https://wwws.appfirst.com/api/servers/6858/data/?num=180",
    success: function(response){
      data = response;
    }
  });

  $.when(req).done(function(){
    var height = 300;
    var width = 1500;

    var svg = d3.select("body").append("svg")
    .attr("width", width)
    .attr("height", height);

    var xscale = d3.scale.linear()
    .domain([data[0].time, data[data.length - 1].time])
    .range([0, width]);

    var yscale = d3.scale.linear()
    .domain([17,55])
    .range([0, height]);

    var xaxis = d3.svg.axis()
    .orient("bottom")
    .scale(xscale)
    .ticks(5)

    var yaxis = d3.svg.axis()
    .scale(yscale)
    .orient("left")
    .ticks(5)

    var line = d3.svg.line()
    .x(function(d){return xscale(d.time)})
    .y(function(d){return height - yscale(d.cpu)})

    var tooltip = d3.select("body")
    .append("div")
    .text("whale")
    .attr("class", "tooltip")
    .style("opacity", -1);

    d3.json("", function(error, json){

      svg.append("path")
      .attr("d", line(data));

      var node = svg.selectAll('node')
      .data(data)
      .enter()
      .append("circle")
      .attr("cx", function(d){return xscale(d.time)})
      .attr("cy", function(d){return height - yscale(d.cpu)})
      .attr("r", 4)
      .on("mouseover", function(d){ 
        tooltip.text("cpu: " + d.cpu)
        .transition()
        .duration(500)
        .style("opacity", 1)
        .style("left", (d3.event.pageX - 90) + "px")
        .style("top", (d3.event.pageY - 20) + "px");
      })
      .on("mouseout", function(d){
        tooltip.transition()
        .duration(200)
        .style("opacity", -1);
      });

      svg.append("g")
      .attr("class", "axis")
      .attr("transform", "translate(0," + height + ")")
      .call(xaxis);

      svg.append("g")
      .attr("class", "axis")
      .call(yaxis);

      console.log(data);
    });
  });
}







