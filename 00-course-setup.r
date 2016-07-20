### -----------------------------
### workshop setup
### simon munzert
### -----------------------------


# install packages from CRAN
p_needed <- c("plyr", "dplyr", "stringr", "lubridate", "jsonlite", "httr", "xml2", "rvest", "devtools", "ggmap",  "networkD3", "RSelenium", "pageviews", "aRxiv", "twitteR", "streamR")
packages <- rownames(installed.packages())
p_to_install <- p_needed[!(p_needed %in% packages)]
if (length(p_to_install) > 0) {
  install.packages(p_to_install)
}

lapply(p_needed, require, character.only = TRUE)
