# ---------------------------------------------------------------------------- #
#' 
#' Description: Construct complete grid cell-by-year panel 
#' Author: Miriam Gold
#' Date: 4 April 2025
#' Last revised: date, initials
#' Notes: 
#' 
# ---------------------------------------------------------------------------- #

# Set up ==========================================

# Read in data ====================================

## River grid ===================
river_grid_sf <-
  path_data_clean_river %>%
  file.path("river_grid", "river_grid.shp") %>%
  read_sf()

# Clean data ======================================

river_year_panel_complete <-
  river_grid_sf %>%
  st_drop_geometry() %>%
  mutate(year = 1990) %>%
  group_by(river_id, on_river) %>%
  complete(
    year = 1990:2022
  ) %>%
  ungroup() %>%
  setDT() %>%
  setkey(river_id, year)

# Analysis ========================================

# Output ==========================================
river_year_panel_complete %>%
  write_parquet(
    file.path(
      path_data_clean_river, 
      "river_year_panel_complete", 
      "river_year_panel_complete.pqt"
      )
  )
