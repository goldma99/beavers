# ---------------------------------------------------------------------------- #
#' 
#' Description: Import and clean rasterized land cover data from UKCEH
#' Author: Miriam Gold
#' Date: 4 May 2024
#' Last revised: date, initials
#' Notes: notes
#' 
# ---------------------------------------------------------------------------- #

# Read in data ====================================

## List of all LCM raster file paths ================ 
path_raster_year_list <-
  path_data_scotland_ukceh %>%
  dir_ls() %>%
  purrr::set_names(~str_extract(.x, "Land Cover Map (\\d{4}) ", group = 1)) %>%
  sort() %>%
  dir_ls(recurse = TRUE, glob = "*.tif$")

## River grid cell polygons

# Process land cover data ======================================

## Determine the proportion of 1km grid cells that are classified as arable/horticulture
path_raster_year_list %>%
  pluck(10) %>%
  walk(process_ukceh)
