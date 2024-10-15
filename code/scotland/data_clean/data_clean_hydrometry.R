# ---------------------------------------------------------------------------- #
#' 
#' Description: Import and clean data from Scottish hydrometry network
#' Author: Miriam Gold
#' Date: 5 April 2024
#' Last revised: 13 April 2024, mag
#' Notes: notes
#' 
# ---------------------------------------------------------------------------- #

# Set up ==========================================

## Load packages ====
#' @Note: Due to a weird issue where the API calls for the timeseries values 
#' were crashing the RStudio session, I opted to run this script as the background
#' job in RStudio, which means I need to load these packages within the script 
#' itself, even though in an interactive session they are redundant of the 
#' _master_scotland.R script 
library(sf)
library(tidyverse)
library(lubridate)
library(httr2)
library(rvest)
library(janitor)
library(magrittr)
library(arrow)

## File system paths ====

# Read in data ====================================

# Agricultural parish polygons
ag_parish_in_survey <-
  path_data_clean_parish %>%
  file.path("ag_parish_in_survey", "ag_parish_in_survey.shp") %>%
  read_sf()

# Clean data ======================================

# 1. Determine the breadth and spatial density of monitoring stations in the Tayside region

hydrometry_stations <- hydrometry_get("station")

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
##' River flow (discharge) in m^3/s: "Q"
##' Groundwater level 
##' Monthly mean and max (Month.Max, Month.Mean)

stations_with_data_in_survey <-
  expand_grid(
    request = "station",
    stationparameter_name = c("Level", "Flow", "GroundwaterLevel"),
    returnfields = "station_name,station_id,stationparameter_name,parametertype_name,station_latitude,station_longitude"
  ) %>%
    pmap(hydrometry_get) %>%
    list_rbind() %>%
    distinct() %>%
    filter(!is.na(station_latitude)) %>%
    st_as_sf(
      coords = c("station_longitude", "station_latitude"),
      crs = 4326
    ) %>%
    st_transform(27700) %>%
    st_filter(ag_parish_in_survey)

survey_stations_ts_metadata <-
  stations_with_data_in_survey %>%
  st_drop_geometry() %>%
  group_by(stationparameter_name) %>%
  summarise(
    station_id = paste0(station_id, collapse = ",")
  ) %>%
  ungroup() %>%
  mutate(
    request = "timeseries",
    ts_shortname = case_when(
      stationparameter_name == "Level" ~ "HMonth.Max,HMonth.Mean",
      stationparameter_name == "Flow" ~ "HDay.Mean,HYear.Max",
      stationparameter_name == "GroundwaterLevel" ~ "HYear.Mean,HYear.Max"
      ),
    returnfields = "station_name, station_no, station_id, station_latitude, station_longitude, stationparameter_name, ts_shortname, ts_id, ts_path, coverage"
  ) %>%
  pmap(hydrometry_get) %>%
  list_rbind() %>%
  filter(!is.na(ts_id))

survey_stations_ts_metadata_clean <-
  survey_stations_ts_metadata %>%
  mutate(
    from_date = as_date(from),
    to_date = as_date(to),
    from = str_sub(from, 1, 7),
    to = str_sub(to, 1, 7),
    station_id = factor(station_id),
    station_id = fct_reorder(station_id, from_date, .desc = TRUE),
    ts_id = as.character(ts_id)
  )

# 3. Determine quality of the data (i.e., do we have a close to balanced panel across all major river segments?

survey_stations_ts_values <-
  survey_stations_ts_metadata_clean %>%
  mutate(request = "timeseries_values",
         returnfields = "Timestamp,Value,Quality Code") %>%
  select(request, ts_path, from, returnfields) %>%
  pmap(hydrometry_get) %>%
  list_rbind()

survey_stations_ts_values_clean <-
  survey_stations_ts_values %>%
  mutate(
    ts_timestamp = as_date(timestamp),
    ) %>%
  rename(ts_value = value) %>%
  filter(!is.na(ts_timestamp)) %>%
  left_join(
    survey_stations_ts_metadata_clean,
    by = c("ts_id")
  ) %>%
  group_by(ts_id) %>%
  mutate(
    ts_timestamp_l1 = lag(ts_timestamp),
    ts_timestamp_diff = ts_timestamp - ts_timestamp_l1,
    ts_timestamp_min = min(ts_timestamp),
    ts_timestamp_max = max(ts_timestamp),
    ts_timestamp_len = difftime(ts_timestamp_max, ts_timestamp_min)
  )
 
# Output ==========================================

## Stations in survey area with level measurements: metadata
survey_stations_ts_metadata_clean %>%
  write_csv(
    file.path(path_data_clean_hydrometry, "survey_stations_ts_metadata.csv")
    )

## Stations in survey area with level measurements: data values
survey_stations_ts_values_clean %>%
  write_parquet(
    file.path(path_data_clean_hydrometry, "survey_stations_ts_values.parquet")
    )
