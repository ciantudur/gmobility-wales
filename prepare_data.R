## -------------------------------------------------------------------------- ##
## Google Mobility Reports - Prepare Data ----------------------------------- ##
## -------------------------------------------------------------------------- ##
## prepare_data.R
## 22 November 2020
## Cian Siôn (SionC1@cardiff.ac.uk)



## REMARKS ---------------------------------------------------------------------
#  This script fetches data from Google and compiles a dataset to be used by 
#  the Shiny app to plot mobility trends for Wales. 

# ! This script requires an internet connection to run.



## GLOBAL PARAMATERS -----------------------------------------------------------
setwd("~/R/Google") # CHANGE AS REQUIRED



## INSTALL REQUIRED PACKAGES ---------------------------------------------------
list.of.packages <- c(
  "sf", "ggplot2", "here", "magrittr", "tidyverse", "readr",
  "RCurl", "datasets", "ggpubr", "imputeTS", "plyr", "forecast", "feather"
)
new.packages <- list.of.packages[!(list.of.packages %in%
  installed.packages()[, "Package"])]
if (length(new.packages)) install.packages(new.packages)

for (pkg in list.of.packages) {
  library(pkg, character.only = TRUE)
}



## FETCH DATA ------------------------------------------------------------------
message("Fetching latest data from Google... this may take up to 15 minutes.")
google_data <- read.csv(
  "https://www.gstatic.com/covid19/mobility/Global_Mobility_Report.csv"
)

# Save input data as CSV with today's date
now <- Sys.time()
file_name <- paste0(format(now, "%d_%m_%Y_"), "google_data.csv")
message("Saving dataset...")
write.csv(google_data, paste0(file_name), row.names = TRUE)



## TRANSFORM DATA --------------------------------------------------------------
google_data_uk <- google_data[google_data$country_region_code == "GB", ]

welshLAs <- c(
  "Isle of Anglesey", "Gwynedd", "Conwy Principal Area",
  "Denbighshire", "Flintshire", "Wrexham Principal Area", "Powys",
  "Ceredigion", "Carmarthenshire", "Pembrokeshire", "Swansea",
  "Bridgend County Borough", "Neath Port Talbot Principle Area",
  "Vale of Glamorgan", "Cardiff", "Newport", "Monmouthshire",
  "Blaenau Gwent", "Torfaen Principal Area",
  "Caerphilly County Borough", "Merthyr Tydfil County Borough",
  "Rhondda Cynon Taff"
)

google_data_wales <- google_data[google_data$sub_region_1 %in% welshLAs, ]
google_data_uk_series <- google_data_uk[google_data_uk$sub_region_1 == "" &
  !is.na(google_data_uk$sub_region_1), ]



## IMPUTE MISSING DATA ---------------------------------------------------------
imputed_data <- google_data_wales

# For each column of data, and for each local authority, check if there are > 3
# non-NA values to perform imputation. If true, impute missing data, unless
# there are more than 30 consecutive NA values. If there are < 4 non-NA values
# in total, leave all missing values as NAs.

message("Imputing missing local authority data...")
for (j in 9:14) {
  for (i in welshLAs) {
    if (sum(!is.na(imputed_data [imputed_data$sub_region_1 == i, j])) > 3) {
      imputed_data [imputed_data$sub_region_1 == i, j] <- na_kalman(
        imputed_data [imputed_data$sub_region_1 == i, j],
        model = "auto.arima", smooth = TRUE, maxgap = 30
      )
    }
    else {

    }
  }
}



## GENERATE ALL WALES SERIES ---------------------------------------------------
imputed_data <- imputed_data[order(
  imputed_data$date,
  imputed_data$sub_region_1
), ]


# Use population weights to calculate weighted average
pop_weights <- read.csv("pop_weights_19.csv", sep = ";")
pop_weights$pop_19_2 <- as.numeric(pop_weights$pop_19)
pop_weights$country <- "Wales"
total_pop <- aggregate(pop_weights$pop_19_2,
  list(pop_weights$country),
  FUN = sum
)
total_pop <- total_pop[, 2]
pop_weights$pop_weight <- pop_weights$pop_19_2 / total_pop

imputed_data <- join(imputed_data, pop_weights, by = "iso_3166_2_code")

imputed_data_2 <- imputed_data[imputed_data$sub_region_1 == "Cardiff", ]
imputed_data_2$sub_region_1 <- "Wales"
imputed_data_2$iso_3166_2_code <- "Wales"
imputed_data_2$la_name_alt <- NULL


# Loop this??
imputed_data_2$retail_and_recreation_percent_change_from_baseline <-
  sapply(
    split(imputed_data, imputed_data$date),
    function(d) {
      weighted.mean(
        d$retail_and_recreation_percent_change_from_baseline,
        w = d$pop_weight,
        na.rm = T
      )
    }
  )

imputed_data_2$grocery_and_pharmacy_percent_change_from_baseline <-
  sapply(
    split(imputed_data, imputed_data$date),
    function(d) {
      weighted.mean(
        d$grocery_and_pharmacy_percent_change_from_baseline,
        w = d$pop_weight,
        na.rm = T
      )
    }
  )

imputed_data_2$parks_percent_change_from_baseline <-
  sapply(
    split(imputed_data, imputed_data$date),
    function(d) {
      weighted.mean(
        d$parks_percent_change_from_baseline,
        w = d$pop_weight,
        na.rm = T
      )
    }
  )

imputed_data_2$transit_stations_percent_change_from_baseline <-
  sapply(
    split(imputed_data, imputed_data$date),
    function(d) {
      weighted.mean(
        d$transit_stations_percent_change_from_baseline,
        w = d$pop_weight,
        na.rm = T
      )
    }
  )

imputed_data_2$workplaces_percent_change_from_baseline <-
  sapply(
    split(imputed_data, imputed_data$date),
    function(d) {
      weighted.mean(
        d$workplaces_percent_change_from_baseline,
        w = d$pop_weight,
        na.rm = T
      )
    }
  )

imputed_data_2$residential_percent_change_from_baseline <-
  sapply(
    split(imputed_data, imputed_data$date),
    function(d) {
      weighted.mean(
        d$residential_percent_change_from_baseline,
        w = d$pop_weight,
        na.rm = T
      )
    }
  )

all_wales <- imputed_data_2[, 8:14]



## JOIN WALES AND UK SERIES INTO ONE DATASET -----------------------------------
all_wales$country <- "Wales"
names(all_wales)[1] <- "date"

google_data_uk_series$country <- "UK"
google_data_uk_series <- google_data_uk_series[,8:15]

uk_wales_data <- rbind(all_wales, google_data_uk_series)
uk_wales_data[, 2:7] <- uk_wales_data[, 2:7] / 100


## RESTORE LA DATA  ------------------------------------------------------------
la_data <- imputed_data[, 8:15]
la_data$country <- la_data$la_name_alt
la_data$la_name_alt <- NULL

for (i in 2:7) {
  la_data[, i] <- la_data[, i] / 100
}

uk_wales_data <- rbind(la_data, uk_wales_data)




## SEASONALITY ADJUSTMENT ------------------------------------------------------
uk_wales_data_sa <- uk_wales_data


# List of areas
areas <- c("Wales", "UK", "Blaenau Gwent", "Bridgend", "Cardiff", "Carmarthenshire",
               "Caerphilly", "Ceredigion", "Conwy", "Denbighshire", "Flintshire",
               "Gwynedd", "Isle of Anglesey", "Merthyr Tydfil", "Monmouthshire",
               "Neath Port Talbot", "Newport", "Pembrokeshire", "Powys",
               "Rhondda Cynon Taf", "Swansea", "Torfaen", "Vale of Glamorgan",
               "Wrexham")


# Seasonally adjust data using ARIMA model
for (i in areas) {
  for (j in 2:7) {
    data_temp <- uk_wales_data_sa[uk_wales_data_sa$country == i, j]
    if (all(!is.na(data_temp))) {
      ts_temp <- ts(data_temp, frequency = 7)
      decompose_temp <- decompose(ts_temp, "additive")
      uk_wales_data_sa[uk_wales_data_sa$country == i, j] <- decompose_temp$trend
    } else {
      uk_wales_data_sa[uk_wales_data_sa$country == i, j] <- NA
    }
  }
}


uk_wales_data_sa <- uk_wales_data_sa[
  !is.na(uk_wales_data_sa$retail_and_recreation_percent_change_from_baseline),
]



## SAVE DATA FOR PLOTTING ------------------------------------------------------
file_name <- "google_data.csv"
write_feather(uk_wales_data_sa, "google_data.feather")

