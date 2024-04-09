# ---------------------------------------------------------------------------- #
#' 
#' Description: Import and clean data from Scottish hydrometry network
#' Author: Miriam Gold
#' Date: 5 April 2024
#' Last revised: date, mag
#' Notes: notes
#' 
# ---------------------------------------------------------------------------- #

# Set up ==========================================

## Load packages ====
library(httr2)
library(rvest)

library(sf)

library(tidyverse)
library(janitor)
library(glue)

## File system paths ====

# Read in data ====================================

# Agricultural parish polygons
ag_parish_in_survey <-
  path_data_clean_parish %>%
  file.path("ag_parish_in_survey.shp") %>%
  read_sf()

# Clean data ======================================

# 1. Determine the breadth and spatial density of monitoring stations in the Tayside region
url <- "https://timeseries.sepa.org.uk/KiWIS/KiWIS?service=kisters&type=queryServices&datasource=0&request=getStationList"

resp <- GET(url)

hydrometry_stations <-
  rawToChar(resp$content) %>%
  read_html() %>%
  html_table(header = 1) %>%
  pluck(1)

hydrometry_stations_sf <-
  hydrometry_stations %>%
  filter(!is.na(station_latitude)) %>%
  st_as_sf(
    coords = c("station_longitude", "station_latitude"),
    crs = 4326
  )

hydrometry_stations_in_survey <-
  hydrometry_stations_sf %>%
  st_transform(crs = 27700) %>%
  st_filter(ag_parish_in_survey) 

ggplot() +
  geom_sf(data = ag_parish_in_survey) +
  geom_sf(data = hydrometry_stations_in_survey, color = "red")

# 2. Determine what measurement time series are available during our period of interest (~1990 -> 2020)

#' @Data-Structure
#' Time series are identified by: site/station/parameter/frequency

##' @Data-Quality
hydrometry_quality_codes <-
  read_html("https://timeseriesdoc.sepa.org.uk/api-documentation/before-you-start/how-data-validity-may-change/") %>%
  html_table() %>%
  pluck(1) %>%
  clean_names()

##' @Variables
##' River Level (stage) in meters: "level"/"SG"
##' Monthly mean and max (Month.Max, Month.Mean)

level_station_url <- "https://timeseries.sepa.org.uk/KiWIS/KiWIS?service=kisters&type=queryServices&datasource=0&request=getstationlist&stationparameter_name=Level&format=csv"

level_station_resp <- GET(level_station_url)

hydrometry_stations_with_level <-
  level_station_resp %>%
  content(as = "text") %>%
  read_delim() %>%
  distinct()

stations_with_level_in_survey <-
  hydrometry_stations_in_survey %>%
  select(station_name) %>%
  inner_join(hydrometry_stations_with_level, by = c("station_name"))

aberlour_level_ts <-
  hydrometry_get("timeseries", station_name = "Aberlour", parametertype_name = "S",
               returnfields = "station_name, station_no, ts_shortname, ts_id, ts_path, coverage",
               dateformat = "yyyy-MM") %>%
  filter(ts_shortname %in% c("HMonth.Max", "HMonth.Mean"))

aberlour_ts_path <-
  aberlour_level_ts %>%
  pull(ts_path) %>%
  pluck(2)

aberlour_level_values <-
  hydrometry_get("timeseries_values", ts_path = aberlour_ts_path, from = "1991-04")

aberlour_level_values %>%
  rename(timestamp = "ts_id", "value" = 2) %>%
  slice(4:n()) %>%
  mutate(timestamp = lubridate::as_datetime(timestamp),
         value = as.numeric(value)) %>%
  ggplot(aes(x = timestamp, y = value)) +
  geom_line() +
  geom_smooth(linewidth = 2, color = "lightblue4", se = FALSE) +
  theme_classic()
  

# 3. Determine quality of the data (i.e., do we have a close to balanced panel across all major river segments?

# Analysis ========================================
sepa_base_url <- "https://timeseries.sepa.org.uk/KiWIS/KiWIS?service=kisters&datasource=0&type=queryServices"

# Output ==========================================


