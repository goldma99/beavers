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
river_network_grouped <-
  river_link_sf %>%
  summarise(link_index = 9999)

river_grid_sf <-
  ## Tessellate the Agricultural parishes...
  st_make_grid(ag_parish_in_survey, cellsize = 1000) %>%
  st_as_sf() %>%
  #rowid_to_column(var = "orig_id") %>%
  st_filter(ag_parish_in_survey) %>%
  ## ...then intersect with river links and mark those that overlap with rivers 
  st_join(river_network_grouped) %>%
  rowid_to_column(var = "river_id") %>%
  mutate(on_river = !is.na(link_index)) %>%
  select(!link_index)
  
# Analysis ========================================

# Output ==========================================
river_grid_sf %>%
  write_sf(
    file.path(path_data_clean_river, "river_grid", "river_grid.shp")
  )

