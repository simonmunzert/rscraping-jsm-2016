### -----------------------------
### simon munzert
### intro to web scraping with R
### -----------------------------

## preparations -----------------------

source("00-course-setup.r")
wd <- getwd()


## case study 1: map breweries in the Chicago area -------

##  goal
# get list of breweries in the Chicago area
# import list in R
# geolocate breweries
# put them on a map


# set temporary working directory
tempwd <- ("data/breweriesChicago")
dir.create(tempwd)
setwd(tempwd)

## step 1: fetch list of cities with breweries
url <- "https://www.google.de/?#q=list+breweries+chicago"
browseURL(url)
url <- "http://thehopreview.com/blog/chicago-brewery-list"
content <- read_html(url, encoding = "utf8")
anchors <- html_nodes(content, css = "#block-yui_3_17_2_8_1438187725105_11398 p")
breweries <- html_text(anchors)
length(breweries)
head(breweries)
breweries <- breweries[-1]


## step 2: geocode breweries
# geocoding takes a while -> store results in local cache file
# 2500 requests allowed per day

locations <- str_extract(breweries, "[[:digit:]].+?–")
locations <- str_replace(locations, "–", ", Chicago, IL")
locations <- locations[!is.na(locations)]

if (!file.exists("breweries_geo.RData")){
  pos <- geocode(locations, source = "google")
  geocodeQueryCheck()
  save(pos, file="breweries_geo.RData")
} else {
  load("breweries_geo.RData")
}
head(pos)


## step 3: plot breweries of Chicago
brewery_map <- get_map(location=c(lon=mean(pos$lon), lat=mean(pos$lat)), zoom="auto", maptype="hybrid")
p <- ggmap(brewery_map) + geom_point(data=pos, aes(x=lon, y=lat), col="red", size=3)
p

## return to base working drive
setwd(wd)



## case study 2: build a network of statisticians -------

## goals

# gather list of statisticians
# fetch Wikipedia entries
# identify links
# construct connectivity matrix
# visualize network


# set temporary working directory
tempwd <- ("data/wikipediaStatisticians")
dir.create(tempwd)
setwd(tempwd)


## step 1: inspect page
url <- "https://en.wikipedia.org/wiki/List_of_statisticians"
browseURL(url)


## step 2: retrieve links
html <- read_html(url)
anchors <- html_nodes(html, xpath = "//ul/li/a[1]")
links <- html_attr(anchors, "href")

links_iffer <-
  seq_along(links) >=
  seq_along(links)[str_detect(links, "Odd_Aalen")] &
  seq_along(links) <=
  seq_along(links)[str_detect(links, "George_Kingsley_Zipf")] &
  str_detect(links, "/wiki/")
links_index <- seq_along(links)[links_iffer]
links <- links[links_iffer]
length(links)


##  step 3: extract names
names <- html_attr(anchors, "title")[links_index]
names <- str_replace(names, " \\(.*\\)", "")


## step 4: fetch personal wiki pages
baseurl <- "http://en.wikipedia.org"
HTML <- list()
Fname <- str_c(basename(links), ".html")
URL <- str_c(baseurl, links)
# loop
for ( i in seq_along(links) ){
  # url
  url <- URL[i]
  # fname
  fname <- Fname[i]
  # download
  if ( !file.exists(fname) ) download.file(url, fname)
  # read in files
  HTML[[i]] <- read_html(fname)
}


## step 5: identify links between statisticians
# loop preparation
connections <- data.frame(from=NULL, to=NULL)
# loop
for (i in seq_along(HTML)) {
  pslinks <- html_attr(
    html_nodes(HTML[[i]], xpath="//p//a"), # note: only look for links in p sections; otherwise too many links collected
    "href")
  links_in_pslinks <- seq_along(links)[links %in% pslinks]
  links_in_pslinks <- links_in_pslinks[links_in_pslinks!=i]
  connections <- rbind(
    connections,
    data.frame(
      from=rep(i-1, length(links_in_pslinks)), # -1 for zero-indexing
      to=links_in_pslinks-1 # here too
    )
  )
}

# results
names(connections) <- c("from", "to")
head(connections)

# make symmetrical
connections <- rbind(
  connections,
  data.frame(from=connections$to,
             to=connections$from)
)
connections <- connections[!duplicated(connections),]


## step 6: visualize connections
connections$value <- 1
nodesDF <- data.frame(name = names, group = 1)

network_out <- forceNetwork(Links = connections, Nodes = nodesDF, Source = "from", Target = "to", Value = "value", NodeID = "name", Group = "group", zoom = TRUE, opacityNoHover = 3)

saveNetwork(network_out, file = 'connections.html')
browseURL("connections.html")


## step 7: identify top nodes in data frame
nodesDF$id <- as.numeric(rownames(nodesDF)) - 1
connections_df <- merge(connections, nodesDF, by.x = "to", by.y = "id", all = TRUE)
to_count_df <- count(connections_df, name)
arrange(to_count_df, desc(n))
