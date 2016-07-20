# A primer to Web Scraping with R

## General information

**Summary**

The web is full of data that are of great interest to scientists and businesses alike. Firms, public institutions, and private users provide every imaginable type of information, and new channels of communication generate vast amounts of data on human behavior. But how to efficiently collect data from the Internet; retrieve information from social networks, search engines, and dynamic web pages; tap web services; and, finally, process the collected data with statistical software? We will learn about the basics of web data collection practice with R. The sessions are hands-on; we will practice every step of the process with R using various examples. We will learn how to scrape content from static and dynamic web pages, connect to APIs from popular web services such as Twitter to read out and process user data, and set up automatically working scraper programs. 

**Event**

Joint Statistical Meetings 2016, Continuing Education Course, Chicago

**Venue**

McCormick Place Convention Center, West Building, W470a

**Instructor** 

Simon Munzert ([website](https://simonmunzert.github.io), [Twitter](https://twitter.com/simonsaysnothin))

**Requirements**

This course assumes prior experience using R. Please bring a laptop with the latest version of R and Rstudio installed (see more below for the technical setup). 

**Time schedule**

|  | Time | Topic |
|--------|-------------------------|---------------------------------------------------------|
| Slot 1 | 8.30 a.m. - 10.15 a.m. | Introduction, setup, and overview |
| Slot 2 | 10.30 a.m. - 12.30 a.m. | Scraping static webpages with rvest |
| Slot 3 | 2.00 p.m. - 3.15 p.m. | Scraping dynamic webpages with RSelenium; good practice |
| Slot 4 | 3.30 p.m. - 5.00 p.m. | Tapping APIs |


## Accompanying book
Together with Christian Rubba, Peter Meissner, and Dominic Nyhuis, I've written a book on [Automated Data Collection with R](http://r-datacollection.com). Participants of the course might find it useful to have it as an accompanying resource. 


## Technical setup for the course

Please make sure that the current version of R is installed. If not, update from here: [https://cran.r-project.org/](https://cran.r-project.org/)

Obviously, feel free to choose the coding environment you feel most comfortable with. I'll use RStudio in the course. You might want to use it, too: [https://www.rstudio.com/products/rstudio/download/](https://www.rstudio.com/products/rstudio/download/)

We are going to need a couple of packages from CRAN: You can install them all by executing the following code chunk:
```r
p_needed <- c("plyr", "dplyr", "stringr", "lubridate", "jsonlite", 
              "httr", "xml2", "rvest", "devtools", "ggmap",
               "networkD3", "RSelenium", "pageviews", "aRxiv", 
               "twitteR", "streamR")
packages <- rownames(installed.packages())
p_to_install <- p_needed[!(p_needed %in% packages)]
if (length(p_to_install) > 0) {
  install.packages(p_to_install)
}
```

Finally, if you want to follow the code on Twitter mining live in the course, please consult the instructions to connect with Twitter as described here (first section, "Connecting with Twitter"): [Connecting with Twitter using R](http://www.r-datacollection.com/blog/How-to-conduct-a-tombola-with-R/)





## Resources
| Area | URL | Short description |
|---------------------------|-------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------|
| Web technologies, general | http://www.w3.org/ | Base of the World Wide Web Consortium (W3C), also provides access to standards and drafts of web technologies |
|  | http://w3schools.com | Great tutorial playground to lern web technologies interactively |
|  | https://w3techs.com/technologies | Overview of all kinds of web technologies |
| XML and XPath | http://selectorgadget.com/ | Probably the most useful tool for generating CSS selectors and XPath expressions with a simple point-and-click approach |
|  | http://www.xmlvalidation.com/ | Online XML validator |
|  | http://www.rssboard.org/ | Information about the Really Simple Syndication standard |
| CSS selectors | http://www.w3schools.com/cssref/css_selectors.asp | W3 Schools CSS reference |
|  | http://flukeout.github.io/ | Interactive CSS selectors tutorial |
| JSON | http://www.json.org/ | Base of the JSON data interchange standard |
|  | http://jsonformatter.curiousconcept.com | Formatting tool for JSON content |
| HTTP | http://httpbin.org | HTTP Request and Response Service; useful to debug HTTP queries |
|  | http://useragentstring.com | Tool to figure out what's behind a User-agent string |
|  | http://curl.haxx.se/libcurl/ | Documentation of the libcurl library |
|  | http://www.robotstxt.org/ | Information about  robots.txt |
| OAuth | http://oauth.net | Information about the Oauth authorization standard |
|  | http://hueniverse.com/oauth | Great overview of Oauth 1.0 |
| Database technologies | http://db-engines.com | Compendium of existing database management systems |
|  | https://www.thoughtworks.com/insights/blog/nosql-databases-overview | Intro to NoSQL databases |
| Regular expressions | http://www.pcre.org/ | Description of Perl Compatible Regular Expressions |
|  | https://stat.ethz.ch/R-manual/R-devel/library/base/html/regex.html | Regular Expressions as used in base R |
|  | http://regexone.com/ | Online regex tutorial |
|  | http://regex101.com | Regex testing environment |
|  | http://www.regexplanet.com/ | Another regex testing environment |
|  | http://stackoverflow.com/questions/1732348/regex-match-open-tags-except-xhtml-self-contained-tags/1732454#1732454 | The truth about HTML parsing with regular expressions |
|  | https://www.youtube.com/watch?v=Cv2DpwSCgRw | Yes, there's a regex song |
| Selenium | http://docs.seleniumhq.org | Selenium documentation |
| APIs | http://www.programmableweb.com/apis | Overview of many existing web APIs |
|  | http://ropensci.org/ | Platform for R packages that provide access to science data repositories |
| R | http://cran.r-project.org/web/views/WebTechnologies.html | CRAN Task View on Web Technologies and Services - useful to stay in the loop of what's possible with R |
|  | http://tryr.codeschool.com/ | An excellent interactive primer for learning R |
|  | http://www.r-bloggers.com/ | Blog aggregator which collects entries from many R-related blogs |
|  | http://planetr.stderr.org | Blog aggregator providing information about new R packages and scientific work related to R |
|  | http://dirk.eddelbuettel.com/cranberries/ | Dirk Eddelbuetttel's CRANberries blog keeps you up-to-date on new and updated R packages |
|  | http://www.omegahat.org/ | Home of the "Omega Project for Statistical Computing"; documentation of many important R packages dealing with web-based data |
|  | https://github.com/ropensci/user2016-tutorial#extracting-data-from-the-web-apis-and-beyond | Web API tutorial from useR 2016 conference by Scott Chamberlain, Karthik Ram, and Garrett Grolemund |
| General web scraping | http://r-datacollection.com | Probably the most useful resource of all |
|  | [http://www.stata-datacollection.com](https://www.youtube.com/watch?v=WOdjCb4LwQY) | Now let's see if that works… |
| Legal issues | http://www.eff.org/ | Electronic Frontier Foundation, a non-profit organisation which advocates digital rights |
|  | http://blawgsearch.justia.com/ | Search engine for law blogs -- useful if you want to stay informed about recent jurisdiction on digital issues |
|  | http://en.wikipedia.org/wiki/Web_scraping | See the section on "Legal issues" |



