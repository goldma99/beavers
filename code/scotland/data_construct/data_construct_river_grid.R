# ---------------------------------------------------------------------------- #
#' 
#' Description: Tessellate river into grid cells, then calculate beaver 
#'              intensity in each by year
#' Author: Miriam Gold
#' Date: 19 April 2024
#' Last revised: date, initials
#' Notes: This is one way I'm attempting to measure the extensive margin of 
#'        beaver presence at any given point
#' 
# ---------------------------------------------------------------------------- #

# Set up ==========================================

## Load packages ====

## File system paths ====

# Read in data ====================================

## River links
river_link_sf <-
  path_data_clean_river %>%
  file.path("scotland_river_links") %>%
  read_geography()

## Ag parish bbox ====
ag_parish_in_survey <-
  path_data_clean_parish %>%
  file.path("ag_parish_in_survey") %>%
  read_geography()

# Clean data ======================================

ag_parish_tessel <-
  st_make_grid(ag_parish_in_survey, cellsize = 1000) %>%
  st_as_sf() %>%
  st_filter(river_link_sf)

ggplot() +
  geom_sf(data = ag_parish_in_survey, fill = "grey90", color = NA) +
  geom_sf(data = ag_parish_tessel, fill = NA, color = "black") +
  geom_sf(data = river_link_sf, color = "blue")

# Analysis ========================================

# Output ==========================================