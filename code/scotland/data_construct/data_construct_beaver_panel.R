# ---------------------------------------------------------------------------- #
#' 
#' Description: Beaver presence by landscape grid and year 
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

## Beaver presence ==============
beaver_survey <- 
  path_data_clean_beaver %>%
  file.path("beaver_survey.pqt") %>%
  read_parquet()

# Clean data ======================================

## River grid ===================
river_grid_sf_clean <- 
  river_grid_sf %>%
  select(river_id)

# Analysis ========================================

## Beaver presence ==============
beaver_by_river_grid_year <- 
  beaver_survey %>%
  select(nbn_atlas_record_id, 
         start_date, 
         effective_survey_year, 
         longitude, 
         latitude) %>%
  st_as_sf(crs = 27700, coords = c("longitude", "latitude")) %>%
  st_join(river_grid_sf_clean) %>%
  st_drop_geometry() %>%
  count(river_id, effective_survey_year) %>%
  rename(year = effective_survey_year, beaver_count = n) %>%
  mutate(beaver_d = as.integer(beaver_count > 0)) %>%
  setDT(key = c("river_id", "year"))

# Output ==========================================

beaver_by_river_grid_year %>%
  write_parquet(
    file.path(path_data_clean_beaver, "beaver_by_river_grid_year.pqt")
  )
