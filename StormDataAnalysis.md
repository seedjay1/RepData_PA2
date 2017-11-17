---
title: "Reproducible Research: Peer-Assessed Project 2"
author: "Christopher Jones"
date: "11/16/2017"
output: 
  html_document:
    echo: true
    code_folding: hide
    keep_md: true
---

## Historical US Storm Data Analysis:
## A survey of historical storm data with respect to population health and economic consequences {.tabset}

### Synopsis:

We examine historical US storm data from NOAA, to assess types of events that are most harmful to human health, and also which types of events have the greatest economic consequences.

Primary findings:  

* Finding 1
* Finding 2
* Finding 3

### Data Loading/Processing

#### Loading:

Loading the data is simple; the code is more lengthy because it is general-purpose, checking for the minimal amount of work to be done to load (need download? need unzip? only need to read the file?).


```r
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
```

```
## Reading data file:
```

```r
str(data.raw)
```

```
## 'data.frame':	902297 obs. of  37 variables:
##  $ STATE__   : num  1 1 1 1 1 1 1 1 1 1 ...
##  $ BGN_DATE  : Factor w/ 16335 levels "1/1/1966 0:00:00",..: 6523 6523 4242 11116 2224 2224 2260 383 3980 3980 ...
##  $ BGN_TIME  : Factor w/ 3608 levels "00:00:00 AM",..: 272 287 2705 1683 2584 3186 242 1683 3186 3186 ...
##  $ TIME_ZONE : Factor w/ 22 levels "ADT","AKS","AST",..: 7 7 7 7 7 7 7 7 7 7 ...
##  $ COUNTY    : num  97 3 57 89 43 77 9 123 125 57 ...
##  $ COUNTYNAME: Factor w/ 29601 levels "","5NM E OF MACKINAC BRIDGE TO PRESQUE ISLE LT MI",..: 13513 1873 4598 10592 4372 10094 1973 23873 24418 4598 ...
##  $ STATE     : Factor w/ 72 levels "AK","AL","AM",..: 2 2 2 2 2 2 2 2 2 2 ...
##  $ EVTYPE    : Factor w/ 985 levels "   HIGH SURF ADVISORY",..: 834 834 834 834 834 834 834 834 834 834 ...
##  $ BGN_RANGE : num  0 0 0 0 0 0 0 0 0 0 ...
##  $ BGN_AZI   : Factor w/ 35 levels "","  N"," NW",..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ BGN_LOCATI: Factor w/ 54429 levels "","- 1 N Albion",..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ END_DATE  : Factor w/ 6663 levels "","1/1/1993 0:00:00",..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ END_TIME  : Factor w/ 3647 levels ""," 0900CST",..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ COUNTY_END: num  0 0 0 0 0 0 0 0 0 0 ...
##  $ COUNTYENDN: logi  NA NA NA NA NA NA ...
##  $ END_RANGE : num  0 0 0 0 0 0 0 0 0 0 ...
##  $ END_AZI   : Factor w/ 24 levels "","E","ENE","ESE",..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ END_LOCATI: Factor w/ 34506 levels "","- .5 NNW",..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ LENGTH    : num  14 2 0.1 0 0 1.5 1.5 0 3.3 2.3 ...
##  $ WIDTH     : num  100 150 123 100 150 177 33 33 100 100 ...
##  $ F         : int  3 2 2 2 2 2 2 1 3 3 ...
##  $ MAG       : num  0 0 0 0 0 0 0 0 0 0 ...
##  $ FATALITIES: num  0 0 0 0 0 0 0 0 1 0 ...
##  $ INJURIES  : num  15 0 2 2 2 6 1 0 14 0 ...
##  $ PROPDMG   : num  25 2.5 25 2.5 2.5 2.5 2.5 2.5 25 25 ...
##  $ PROPDMGEXP: Factor w/ 19 levels "","-","?","+",..: 17 17 17 17 17 17 17 17 17 17 ...
##  $ CROPDMG   : num  0 0 0 0 0 0 0 0 0 0 ...
##  $ CROPDMGEXP: Factor w/ 9 levels "","?","0","2",..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ WFO       : Factor w/ 542 levels ""," CI","$AC",..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ STATEOFFIC: Factor w/ 250 levels "","ALABAMA, Central",..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ ZONENAMES : Factor w/ 25112 levels "","                                                                                                               "| __truncated__,..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ LATITUDE  : num  3040 3042 3340 3458 3412 ...
##  $ LONGITUDE : num  8812 8755 8742 8626 8642 ...
##  $ LATITUDE_E: num  3051 0 0 0 0 ...
##  $ LONGITUDE_: num  8806 0 0 0 0 ...
##  $ REMARKS   : Factor w/ 436774 levels "","-2 at Deer Park\n",..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ REFNUM    : num  1 2 3 4 5 6 7 8 9 10 ...
```

#### Processing:

From the raw data, we perform the following processing steps:

* Subset out the columns needed to analyze storm event consequences on population health and the economy
* Convert dollar value orders of magnitude into actual dollar amounts
* Anything else


```r
data.proc <- data.raw[,c("EVTYPE", "FATALITIES", "INJURIES", "PROPDMG","PROPDMGEXP","CROPDMG","CROPDMGEXP")]

denominations <- list(list(c('h', 'H'), 2)
                      , list(c('t', 'T'), 3)
                      , list(c('m', 'M'), 6)
                      , list(c('b', 'B'), 9)
                  )
```

### Results: Health

Instructions:

>What is mean total number of steps taken per day?
>
>For this part of the assignment, you can ignore the missing values in the dataset.
>
>Make a histogram of the total number of steps taken each day
>
>Calculate and report the mean and median total number of steps taken per day

The required information is provided by the plot below, using the complete observations dataset, per the instructions.


```r
1+1
```

```
## [1] 2
```


### Results: Economic

Instructions:

>What is the average daily activity pattern?
>
>Make a time series plot (i.e. type = "l") of the 5-minute interval (x-axis) and the average number of steps taken, averaged across all days (y-axis)
>
>Which 5-minute interval, on average across all the days in the dataset, contains the maximum number of steps?

In addition to answering the questions given, I've provided a smoothing line. The average daily activty pattern is depicted below. On average, the maximum number of steps occurs at interval 835.


```r
2+2
```

```
## [1] 4
```


### References

Instructions:

>Note that there are a number of days/intervals where there are missing values (coded as NA). The presence of missing days may introduce bias into some calculations or summaries of the data.
>
>Calculate and report the total number of missing values in the dataset (i.e. the total number of rows with NAs)
>
>Devise a strategy for filling in all of the missing values in the dataset. The strategy does not need to be sophisticated.
>
>For example, you could use the mean/median for that day, or the mean for that 5-minute interval, etc.
>
>Create a new dataset that is equal to the original dataset but with the missing data filled in.
>
>Make a histogram of the total number of steps taken each day and Calculate and report the mean and median total number of steps taken per day. Do these values differ from the estimates from the first part of the assignment? What is the impact of imputing missing data on the estimates of the total daily number of steps?


For missing values, we use the predictive mean matching method from the commonly-used mice package (2 data sets, 10 iterations).

Finally, we perform the imputation, and produce a before/after comparative visual:


```r
3+3
```

```
## [1] 6
```

This plot contains 2 parts: a before/after histogram, and before/after linear density plots along the top and bottom borders. 

Overall the imputation didn't affect the character of the data very much (at least not visible in the histogram). Most of the new weight was added above the mean/median (they're close together), so the immputed mean/median ticked upwards slightly. And since most of the added weight was near the mean/median, the standard deviation shows a bit of a decrease.


fin

