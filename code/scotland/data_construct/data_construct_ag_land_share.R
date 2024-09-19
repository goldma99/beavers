# ---------------------------------------------------------------------------- #
#' 
#' Description: Calculate proportion of river grid cells that are classified 
#'              as agricultural land use
#' Author: Miriam Gold
#' Date: 16 Sept 2024
#' Last revised: 17 Sept 2024, mag
#' Notes: notes
#' 
# ---------------------------------------------------------------------------- #

# Read in data ====================================

## River grid cell polygons ==========
river_grid_vector <-
  path_data_clean_river %>% 
  file.path("river_grid", "river_grid.shp") %>%
  vect()

## 25x25m Land Cover Maps ========
path_raster_year_list <-
  path_data_scotland_ukceh %>%
  dir_ls(recurse = TRUE, glob = "*.tif$")

# Calculate agricultural land share by river grid cell ================
lcm_years <- c(1990, 2000, 2007, 2015, 2017:2022)

lcm_years %>% 
  walk(
    ~ agg_ukceh.river(.x, river_grid_vector)
  )
