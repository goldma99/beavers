# ---------------------------------------------------------------------------- #
#' 
#' Description: Import and tidy all generic geographical datasets
#' Author: Miriam Gold
#' Date: 4 May 2024
#' Last revised: date, initials
#' Notes: By "generic" I mean any broader-scale geo datasets that are used as 
#'        reference. For instance, a map of the entire country Scotland
#' 
# ---------------------------------------------------------------------------- #

# Set up ==========================================

## Load packages ====

## File system paths ====
path_data_geo <- file.path(path_data_scotland, "geography")

# Read in data ====================================
nuts_sf <-
  path_data_geo %>%
  file.path("NUTS_RG_03M_2021_4326", "NUTS_RG_03M_2021_4326.shp") %>%
  read_sf()

# Clean data ======================================
nuts_scotland <-
  nuts_sf %>%
  clean_names() %>%
  filter(levl_code == 1,
         str_detect(nuts_name, "Scotland"))

# Analysis ========================================

# Output ==========================================
nuts_scotland %>%
  write_sf(
    file.path(path_data_clean, "geography", "nuts_scotland", "nuts_scotland.shp")
  )
