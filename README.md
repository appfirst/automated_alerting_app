# Automated Alerting for AppFirst

![x](https://raw.github.com/appfirst/automated_alerting_app/master/public/screenshot.png)

Automated alerting system based on Etsy’s Skyline.
Concept is to detect single point anomalies without the need to configure thresholds for each alert. Clients may not know what appropriate thresholds are, or may not want to spend a large quantity of time on configuration.

Once an anomaly is detected, this “alert” is pushed to the webapp where the graphs can be viewed and anomalies acted upon. One possible addition to the webapp would be to locate the process that caused the alert once it has been detected. Then, information could be displayed about these processes to aid in debugging.

Application that will allow the user to select the server and attributes that they wish to monitor. The application will issue "alerts" (will be entered into a database) when a set of three data points is outside of three standard deviations of the mean. Working on support for other algorithms to increase sensitvity of the checks (the Grubbs test, in particular).

Created for AppFirst internship 2013.

## Algorithms

Two algoriths were used to detect these single point anomalies. 

### Grubbs Test
Used to detect a single outlier in a univariate set of data that follows a normal distribution.

Algorithm as per Wikipedia: 
<img src='https://raw.github.com/appfirst/automated_alerting_app/master/public/algorithm.png' height='190' width='822'></img>

A time series is anomalous if the Z score is greater than the grubbs score. The Z score is the representation of how many standard deviations it is from the mean.

Of course, our data does not generally follow a normal distribution. So, one option is to normalize the data before performing this test, which could lead to some interesting graphs.

### Standard Test

A time series is anomalous if the absolute value of the average of the latest three data points minus the moving average is greater than one standard deviation of the average.

## Implementation

This application was built in Ruby on Rails with a MongoDB backend. Most of the data is gathered using real-time API calls to the AppFirst API. The database is used to store information on which servers and attributes should be monitored as well as which servers currently exist in the pod.


Please take a look at the second application from this internship, Pod Architecure, [here](https://github.com/alexandraorth/server_architecture)