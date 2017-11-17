# summary: analyze noaa storm data, per course instructions

# =======================
# Data loader
# =======================

# packages we'll be using
library(plyr)
library(ggplot2)

# download data if it isn't already in place in current directory
filename <- "repdata_data_StormData"
extension.data <- ".csv"
extension.zip <- ".bz2"
zipurl <- "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2"

if (!file.exists(paste(filename, extension.data, sep=''))) 
{
  message("Data file not found, checking for data zip file
          ")
  if (!file.exists(paste(c(filename, extension.data, extension.zip), collapse='')))
  {
    message("Data zip file not found. Downloading.")
    
    download <- download.file(zipurl, destfile=paste(c(filename, extension.data, extension.zip), collapse=''))
    foundzip <- TRUE
    
    message("Data zip file downloaded.")
  } else
  {
    foundzip <- TRUE
  }
  
  if (foundzip)
  {
    message("Found data zip file, unzipping.")
    
    library(R.utils)
    bunzip2(paste(c(filename, extension.data, extension.zip), collapse='')
            , paste(c(filename, extension.data), collapse='')
            , remove = FALSE
            , overwrite = TRUE
            )
    unlink(paste(filename, extension.zip, sep=''))
    
    message("Data zip file unzipped.")
  }
  
  if (file.exists(paste(filename, extension.data, sep=''))) 
  {
    message("Data file exists, ready for preprocessing")
  } else
  {
    stop("Data file not found, reason unknown. Halting execution.")
  }
}

# read data only if not already loaded
readdata <- TRUE
if (exists("data.raw"))
{
  if(nrow(data.raw) == 902297) # hardcoding numbers is bad m'kay? saves time though.
  {
    readdata <- FALSE
  }
}
if (readdata)
{
  message("Reading data file:")
  data.raw <- read.csv(paste(filename, extension.data, sep=''), header=TRUE)
}

# str(data.raw)

# Data processing

# project out the columns we're interested in
data.proc <- data.raw[,c("EVTYPE", "FATALITIES", "INJURIES", "PROPDMG","PROPDMGEXP","CROPDMG","CROPDMGEXP")]

# perform order of magnitude calculation to get actual dollar amounts for prop & crop damage
#data.proc$prop_dmg <- data.proc$PROPDMG * sapply(data.proc$PROPDMGEXP, function(str_exp) {switch(tolower(str_exp), "h" = 100, "k" = 1000, "m" = 1000000, "b" = 1000000000, 0)})
#data.proc$crop_dmg <- data.proc$CROPDMG * sapply(data.proc$CROPDMGEXP, function(str_exp) {switch(tolower(str_exp), "h" = 100, "k" = 1000, "m" = 1000000, "b" = 1000000000, 0)})

data.proc$prop_dmg <- data.proc$PROPDMG * sapply(data.proc$PROPDMGEXP, function(str_exp) {switch(tolower(str_exp), "h" = 100, "k" = 1000, "m" = 1000000, "b" = 1000000000, if (is.numeric(str_exp)) 10 ** as.numeric(str_exp) else 1)})
data.proc$crop_dmg <- data.proc$CROPDMG * sapply(data.proc$CROPDMGEXP, function(str_exp) {switch(tolower(str_exp), "h" = 100, "k" = 1000, "m" = 1000000, "b" = 1000000000, if (is.numeric(str_exp)) 10 ** as.numeric(str_exp) else 1)})

# create totals by event for prop & crop damage value
econ_dmg <- ddply(data.proc, .(EVTYPE), summarize, prop_dmg = sum(prop_dmg), crop_dmg = sum(crop_dmg))

# only interested in events with damage
econ_dmg <- econ_dmg[(econ_dmg$prop_dmg > 0 | econ_dmg$crop_dmg > 0), ]

# create totals by event for health damage
health_dmg <- ddply(data.proc, .(EVTYPE), summarize, fat = sum(FATALITIES), inj = sum(INJURIES))

# create running total and % of total
propDmgSorted <- econ_dmg[order(econ_dmg$prop_dmg, decreasing = T), ]
propDmgSorted$cum <- cumsum(propDmgSorted$prop_dmg)
propDmgSorted$running_pct <- propDmgSorted$cum / sum(propDmgSorted$prop_dmg)

cropDmgSorted <- econ_dmg[order(econ_dmg$crop_dmg, decreasing = T), ]
cropDmgSorted$cum <- cumsum(cropDmgSorted$crop_dmg)
cropDmgSorted$running_pct <- cropDmgSorted$cum / sum(cropDmgSorted$crop_dmg)

head(propDmgSorted[, c("EVTYPE", "prop_dmg")], 5)
head(cropDmgSorted[, c("EVTYPE", "crop_dmg")], 5)

# we take 90% of total damage as threshhold to include in report, 
# and create an Others event category for the rest.
threshhold <- .9
propDmgReportData <- propDmgSorted[propDmgSorted$running_pct <= threshhold, ]

propDmgReportData <- rbind(propDmgReportData, c("Other"
                                              , sum(propDmgSorted$prop_dmg) - max(propDmgReportData$cum)
                                              , 0
                                              , sum(propDmgSorted$prop_dmg)
                                              , 1
                                              )
                                            )
propDmgReportData$prop_dmg <- as.numeric(propDmgReportData$prop_dmg)
propDmgReportData$crop_dmg <- as.numeric(propDmgReportData$crop_dmg)
propDmgReportData$cum <- as.numeric(propDmgReportData$cum)
propDmgReportData$running_pct <- as.numeric(propDmgReportData$running_pct)

cropDmgReportData <- cropDmgSorted[cropDmgSorted$running_pct <= threshhold, ]
cropDmgReportData <- rbind(cropDmgReportData, c("Other"
                             , sum(cropDmgSorted$crop_dmg) - max(cropDmgReportData$cum)
                              , 0
                              , sum(cropDmgSorted$crop_dmg)
                              , 1
                              )
                            )
cropDmgReportData$prop_dmg <- as.numeric(cropDmgReportData$prop_dmg)
cropDmgReportData$crop_dmg <- as.numeric(cropDmgReportData$crop_dmg)
cropDmgReportData$cum <- as.numeric(cropDmgReportData$cum)
cropDmgReportData$running_pct <- as.numeric(cropDmgReportData$running_pct)