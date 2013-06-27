<h2> AppFirst Internship Summer 2013 -- Alexandra Orth </h2>

Semi-automatic AppFirst Alerting

Application that will allow the user to select the server and attributes that they wish to monitor. The application will issue "alerts" (will be entered into a database) when a set of three data points is outside of three standard deviations of the mean. Working on support for other algorithms to increase sensitvity of the checks (the Grubbs test, in particular).

Application's current status:
<ul>
	<li> Central graph template with view of current servers' CPU </li>
	<li> Working with algorithms that compares standad deviation and mean </li>
	<li> Can select server and attribute you wish to monitor </li>
	<li> Analyses is automated </li>
</ul>

To be completed
<ul>
	<li> Graphs that show multiple servers/selected attribute </li>
	<li> Implement multiple anomaly-recognizing algorithms </li>
	<li> Support for multiple attributes</li>
</ul>


From previous application:

First visualization using d3.js. "Bubbles" created based on server's "capacity_mem" attribute. Colors intensity is also determined using the "capactiy_mem" attribute. 

Second visualization: Attempt to create a topographic map with server locations. Abandoned.

Third visualization: Graph of "cpu" attribute of server 6858 for the past three hours. Beginning of app idea. Graph currently is static, except for "tooltips" that display data on rollover.


.gitignore includes:
	<ul>
	<li> /tmp </li>
	<li> /db </li>
	<li> *.json </li>
	<li> *.yml </li>
	<li> config/environments </li>
	</ul>
