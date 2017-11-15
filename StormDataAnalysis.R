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
  if (!file.exists(paste(filename, extension.zip, sep='')))
  {
    message("Data zip file not found. Downloading.")
    
    download <- download.file(zipurl, destfile = "temp.zip")
    foundzip <- TRUE
    
    message("Data zip file downloaded.")
  } else
  {
    foundzip <- TRUE
  }
  
  if (foundzip)
  {
    message("Found data zip file, unzipping.")
    
    unzip("temp.zip")
    unlink("temp.zip")
    
    message("Data zip file unzipped.")
  }
  
  if (!file.exists(paste(filename, extension.data, sep=''))) 
  {
    message("Data file exists, ready for preprocessing")
  } else
  {
    stop("Data file not found, reason unknown. Halting execution.")
  }
}

if(nrow(data.raw) != 902298)
{
  message("Reading data file:")
  data.raw <- read.csv(paste(filename, extension.data, sep=''), header=FALSE)
}

str(data.raw)

