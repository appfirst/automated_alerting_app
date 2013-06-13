<h1> AppFirst Internship Summer 2013 -- Alexandra Orth </h1>

Concept (temporary): Rails app that will link to the different data views.

First visualization using d3.js. "Bubbles" created based on server's "capacity_mem" attribute. Colors intensity is also determined using the "capactiy_mem" attribute. 

Second visualization: Attempt to create a topographic map with server locations. Abandoned.

Third visualization: Graph of "cpu" attribute of server 6858 for the past three hours. Beginnging of app idea. Graph currently is static, except fot "tooltips" that display data on rollover.

App idea: System that can recongize outlying points in data and alert the user when outlying data recoours multiple times. This would apply to graphs of most of the data that AppFirst brings in- which makes it relativly daunting. 
	1) Create graph template
	2) Create algorithms that will recognize outlying points (over 24 hour period?)
	3) Test algorithms on first graph.
	4) Figure out way to intercept data? Does not seem efficient to be making so many API calls at once.
	5) To be continued/implementation.


Working on: d3.js topographic visualization of server location. Graphs, graphs, graphs.

.gitignore includes:
	/tmp
	/db
	*.json
	*.yml
	config/environments

Note: Front page up and running. Using Bootstrap so everything doesn't look so clunky.

Note: No database setup