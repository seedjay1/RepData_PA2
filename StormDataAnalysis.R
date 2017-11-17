# summary: analyze noaa storm data, per course instructions

# =======================
# Data loader
# =======================

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
  if(nrow(data.raw) == 902297) # hardcoding numbers is bad m'kay?
  {
    readdata <- FALSE
  }
}
if (readdata)
{
  message("Reading data file:")
  data.raw <- read.csv(paste(filename, extension.data, sep=''), header=TRUE)
}

str(data.raw)

data.proc <- data.raw[,c("EVTYPE", "FATALITIES", "INJURIES", "PROPDMG","PROPDMGEXP","CROPDMG","CROPDMGEXP")]

denominations <- list(list(c('h', 'H'), 2)
                      , list(c('t', 'T'), 3)
                      , list(c('m', 'M'), 6)
                      , list(c('b', 'B'), 9)
                  )

