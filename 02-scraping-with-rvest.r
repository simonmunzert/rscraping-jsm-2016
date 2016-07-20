### -----------------------------
### simon munzert
### scraping with rvest
### -----------------------------

## peparations -------------------

source("00-course-setup.r")
wd <- getwd()


## breaking up the HTML ----------

## What's HTML?

# HyperText Markup Language
# markup language = plain text + markups
# standard for the construction of websites
# relevance for web scraping: web architecture is important because it determines where and how information is stored


## browsing vs. scraping

# browsing
  # 1. you click on something
  # 2. browser sends request to server that hosts website
  # 3. server returns resource (often an HTML document)
  # 4. browser interprets HTML and renders it in a nice fashion

# scraping with R
  # 1. you manually specify a resource
  # 2. R sends request to server that hosts website
  # 3. server returns resource
  # 4. R parses HTML (i.e., interprets the structure), but does not render it in a nice fashion
  # 5. it's up to you to tell R which parts of the structure to focus on and what content to extract


## inspect the source code in your browser ---------------

browseURL("https://www.buzzfeed.com/?country=us")

# Chrome:
  # 1. right click on page
  # 2. select "view source"

# Firefox:
  # 1. right click on page
  # 2. select "view source"

# Microsoft Edge:
# 1. right click on page
# 2. select "view source"

# Safari
  # 1. click on "Safari"
  # 2. select "Preferences"
  # 3. go to "Advanced"
  # 4. check "Show Develop menu in menu bar"
  # 5. click on "Develop"
  # 6. select "show page source"
  # 7. alternatively to 5./6., right click on page and select "view source"


## a quick primer to CSS selectors ----------

## What's CSS?

# Cascading Style Sheets
# style sheet language to give browsers information of how to render HTML document by providing more info on, e.g., layout, colors, and fonts
# CSS code can be sotre within an HTML document or in an external CSS file
# the good thing for us: selectors, i.e. patterns used to specify which elements to format in a certain way, can be used to address the elements we want to extract information from
# works via tag name (e.g., <h2>, <p>, ...) or element attributes "id" and "class"

## How does it work?
browseURL("http://flukeout.github.io/") # let's play this together until plate 8 or so!


#######################
### IT'S YOUR SHOT! ###
#######################

# 1. repeat playing CSS diner until plate 10!
# 2. go to the following website
browseURL("https://www.jstatsoft.org/about/editorialTeam")
  # a) which CSS identifiers can be used to describe all names of the editorial team?
  # b) write a corresponding CSS selector that targets them!


## a quick primer to XPath ------------------

# XPath is a query language for selecting nodes from an XML-style document (including HTML)
# provides just another way of extracting data from static webpages
# you can also use XPath with R
# can be more powerful than CSS selectors
# learning XPath takes probably a day (and some practice) 
# you'll probably not need it, so we don't talk about it here
# if you want to know more, consult our book--we give it an extensive treatment



## the rvest package ----------

## overview 

  # see also: https://github.com/hadley/rvest
  # convenient package to scrape information from web pages
  # builds on other packages like xml2 and httr
  # provides very intuitive functions to import and process webpages


## basic workflow of scraping with rvest

# 1. specify URL
url <- "https://www.buzzfeed.com/?country=us"
# 2. download static HTML behind the URL and parse it into an XML file
url_parsed <- read_html(url)
class(url_parsed)
html_structure(url_parsed)
as_list(url_parsed)
# 3. extract specific nodes with CSS (or XPath)
headings_nodes <- html_nodes(url_parsed, css = ".lede__link")
# 4. extract content from nodes
headings <- html_text(headings_nodes)
headings <- str_replace_all(headings, "\\n", "") %>% str_trim()


#######################
### IT'S YOUR SHOT! ###
#######################

# 1. revisit the jstatsoft.org website from above and use rvest to extract the names!
# 2. bonus: try and extract the full lines including the affiliation and count how many of the editors are at a statistics or mathematics department or institution!



### extract data from tables --------------

## HTML tables 
  # ... are a special case for scraping because they are already very close to the data structure you want to build up in R
  # ... come with standard tags and are usually easily identifiable

## scraping HTML tables with rvest

url <- "https://en.wikipedia.org/wiki/Joint_Statistical_Meetings"
url_parsed <- read_html(url)
tables <- html_table(url_parsed, fill = TRUE)
tables
meetings <- tables[[2]]
class(meetings)
head(meetings)
table(meetings$Location) %>% sort()

## note: HTML tables can get quite complex. there are more flexible solutions than html_table() on the market (e.g., package "htmltab") 


#######################
### IT'S YOUR SHOT! ###
#######################

# 1. scrape the table tall buildings (300m+) currently under construction from
browseurl("https://en.wikipedia.org/wiki/List_of_tallest_buildings_in_the_world")

# 2. how many of those buildings are currently built in China? and in which city are most of the tallest buildings currently built?



### working with SelectorGadget ----------

# to learn about it, visit
vignette("selectorgadget")

# to install it, visit
browseURL("http://selectorgadget.com/")
# and follow the advice below: "drag this link to your bookmark bar: >>SelectorGadget>> (updated August 7, 2013)"

## SelectorGadget is magic. Proof:
browseurl("https://www.buzzfeed.com/?country=us")


#######################
### IT'S YOUR SHOT! ###
#######################

# 1. use SelectorGadget to identify a CSS selector that helps extract all article author names from Buzzfeed's main page!
# 2. use rvest to scrape these names!




## dealing with multiple pages ----------

# often, we want to scrape data from multiple pages
# these are the cases where automating the scraping becomes  r e a l l y  powerful
# my philosophy: download first, then import and extract information. minimizes server load and saves time


## example: fetching and analyzing jstatsoft download statistics

# set temporary working directory
tempwd <- ("data/jstatsoftStats")
dir.create(tempwd)
setwd(tempwd)

browseURL("http://www.jstatsoft.org/")

# construct list of urls
baseurl <- "http://www.jstatsoft.org/article/view/v"
volurl <- paste0("0", seq(1,71,1))
volurl[1:9] <- paste0("00", seq(1, 9, 1))
brurl <- paste0("0", seq(1,9,1))
urls_list <- paste0(baseurl, volurl)
urls_list <- paste0(rep(urls_list, each = 9), "i", brurl)
names <- paste0(rep(volurl, each = 9), "_", brurl, ".html")

# download pages
folder <- "html_articles/"
dir.create(folder)
for (i in 1:length(urls_list)) {
  if (!file.exists(paste0(folder, names[i]))) {
    download.file(urls_list[i], destfile = paste0(folder, "/", names[i]))
    Sys.sleep(runif(1, 0, 1))
  }
}

# check success
list_files <- list.files(folder, pattern = "0.*")
list_files_path <-  list.files(folder, pattern = "0.*", full.names = TRUE)
length(list_files)

# delete non-existing articles
files_size <- sapply(list_files_path, file.size)
table(files_size)
delete_files <- list_files_path[files_size == 22094]
sapply(delete_files, file.remove)
list_files_path <-  list.files(folder, pattern = "0.*", full.names = TRUE) # update list of files

# import pages and extract content
authors <- character()
title <- character()
statistics <- character()
numViews <- numeric()
datePublish <- character()
for (i in 1:length(list_files_path)) {
  html_out <- read_html(list_files_path[i])
  table_out <- html_table(html_out, fill = TRUE)[[6]]
  authors[i] <- table_out[1,2]
  title[i] <- table_out[2,2]
  statistics[i] <- table_out[4,2]
  numViews[i] <- statistics[i] %>% str_extract("[[:digit:]]+") %>% as.numeric()
  datePublish[i] <- statistics[i] %>% str_extract("[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}.$") %>% str_replace("\\.", "")
}


# construct data frame
dat <- data.frame(authors = authors, title = title, numViews = numViews, datePublish = datePublish)
head(dat)

# download statistics
dattop <- dat[order(dat$numViews, decreasing = TRUE),]
dattop[1:10,]
summary(dat$numViews)
plot(density(dat$numViews), yaxt="n", ylab="", xlab="Number of views", main="Distribution of article page views in JSTATSOFT")


