### -----------------------------
### simon munzert
### tapping apis
### -----------------------------

## peparations -------------------

source("00-course-setup.r")
wd <- getwd()



## ready-made R bindings to web APIs ---------

## overview
browseURL("http://ropensci.org/")
browseURL("https://github.com/ropensci/opendata")
browseURL("https://cran.r-project.org/web/views/WebTechnologies.html")


## example: arxiv.org API

# overview and documentation: 
browseURL("http://arxiv.org/help/api/index")
browseURL("http://arxiv.org/help/api/user-manual")

# access api manually:
browseURL("http://export.arxiv.org/api/query?search_query=all:forecast")
forecast <- read_xml("http://export.arxiv.org/api/query?search_query=all:forecast")
xml_ns(forecast) # inspect namespaces
authors <- xml_find_all(forecast, "//d1:author", ns = xml_ns(forecast))
authors %>% xml_text()

# use ready-made binding, the aRxiv package
library(aRxiv)

# overview 
browseURL("http://ropensci.org/tutorials/arxiv_tutorial.html")
ls("package:aRxiv")

# access API with wrapper
?arxiv_search
arxiv_df <- arxiv_search(query = "forecast AND submittedDate:[2016 TO 2017]", limit = 500, output_format = "data.frame")
View(arxiv_df)

arxiv_count('au:"Gary King"')
query_terms

arxiv_count('abs:"political" AND submittedDate:[2016 TO 2017]')
polsci_articles <- arxiv_search('abs:"political" AND submittedDate:[2016 TO 2017]', limit = 500)


#######################
### IT'S YOUR SHOT! ###
#######################

# 1. familiarize yourself with the pageviews package! what functions does it provide and what do they do?
# 2. use the package to fetch page view statistics for the articles about Donald Trump and Hillary Clinton on the English Wikipedia, and plot them against each other in a time series graph!




## accessing APIs from scratch ---------

# most modern APIs use HTTP (HyperText Transfer Protocol) for communication and data transfer between server and client
# R package httr as a good-to-use HTTP client interface
# most web data APIs return data in JSON or XML format
# R packages jsonlite and xml2 good to process JSON or XML-style data

# simple HTTP communication
library(httr)
x <- GET("https://google.com")
x

# if you want to tap an existing API, you have to
  # figure out how it works (what requests/actions are possible, what endpoints exist, what )
  # (register to use the API)
  # formulate queries to the API from within R
  # process the incoming data

## example: connecting with the Open Movie Database API

# information about the API
browseURL("http://www.omdbapi.com/")

# let's try it out
title <- "Groundhog Day" %>% URLencode()
endpoint <- "http://www.omdbapi.com/?"
url <- paste0(endpoint, "t=", title, "&tomatoes=true")
omdb_res = GET(url)
res_list <- content(omdb_res, as =  "parsed")
res_list %>% unlist() %>% t() %>% data.frame(stringsAsFactors = FALSE)

# alternative search
url <- paste0(endpoint, "s=", title)
omdb_res = GET(url)
res_list <- content(omdb_res, as = "text") %>% jsonlite::fromJSON(flatten = TRUE)
res_list$Search

# do we really have to do this manually?
browseURL("https://github.com/hrbrmstr/omdbapi")

#######################
### IT'S YOUR SHOT! ###
#######################

# 1. familiarize yourself with the OpenWeatherMap API!
browseURL("http://openweathermap.org/current")
# 2. sign up for the API at the address below and obtain an API key!
browseURL("http://openweathermap.org/api")
# 3. make a call to the API to find out the current weather conditions in Chicago!





## mining Twitter with R ----------------

## about the Twitter APIs

# two APIs types of interest:
# REST APIs --> reading/writing/following/etc., "Twitter remote control"
# Streaming APIs --> low latency access to 1% of global stream - public, user and site streams
# authentication via OAuth
# documentation at https://dev.twitter.com/overview/documentation

# how to get started
# 1. register as a developer at https://dev.twitter.com/ - it's free
# 2. create a new app at https://apps.twitter.com/ - choose a random name, e.g., MyTwitterToRApp
# 3. go to "Keys and Access Tokens" and keep the displayed information ready
# 4. paste your consumer key and secret into the following code and execute it:

# store credentials in the R environment (uncomment the following lines if you want to store your credentials)
# credentials <- c(
#   "twitter_api_key=rN3Td2zZADLWZBN9Pj7X2eBN",
#   "twitter_api_secret=abcqBpUzE7BQ65QJ6BRzpUzjyaRCfwn3ndrUUcqDWfhCN7Fj")
# fname <- paste0(normalizePath("~/"),".Renviron")
# writeLines(credentials, fname)


## working with the twitteR package

# negotiate credentials
api_key <- Sys.getenv("twitter_api_key")
api_secret <- Sys.getenv("twitter_api_secret")
setup_twitter_oauth(api_key,api_secret)

# search tweets on twitter
tweets <- searchTwitter(searchString = "Trump", n=25)
tweets_df <- twListToDF(tweets)
head(tweets_df)
names(tweets_df)

# get information about users
user <- getUser("RDataCollection")
user$name
user$lastStatus
user$followersCount
user$statusesCount
user_followers <- user$getFollowers()
user_friends <- user$getFriends() 
user_timeline <- userTimeline(user, n=20)
timeline_df <- twListToDF(user_timeline)
head(timeline_df)

# check rate limits
getCurRateLimitInfo()


## working with the streamR package

load("../rscraping-intro-duke-2/twitter_auth.RData")

filterStream("tweets_stream.json", track = c("Trump"), timeout = 10, oauth = twitCred)
tweets <- parseTweets("tweets_stream.json", simplify = TRUE)
names(tweets)
cat(tweets$text[1])



