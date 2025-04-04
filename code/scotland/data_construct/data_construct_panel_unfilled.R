# ---------------------------------------------------------------------------- #
#' 
#' Description: Merge beaver presence, river level, and land use data at the 
#'              river grid cell-year level
#' Author: Miriam Gold
#' Date: 23 Sept 2024
#' Last revised: date, mag
#' Notes: notes
#' 
# ---------------------------------------------------------------------------- #

# Set up ==========================================

## Load packages ====

## File system paths ====

# Read in data ====================================
river_year_panel_complete <-
  path_data_clean_river %>% 
  file.path(
    "river_year_panel_complete",
    "river_year_panel_complete.pqt"
    ) %>% 
  read_parquet()

## Beaver presence by grid cell and year ========
beaver_by_river_grid_year <-
  path_data_clean_beaver %>% 
  file.path("beaver_by_river_grid_year.pqt") %>% 
  read_parquet()

## River measurements panel =================
hydrometry_by_river_grid_year <-
  path_data_clean_hydrometry %>%
  file.path("hydrometry_by_river_grid_year.pqt") %>% 
  read_parquet() %>% 
  setDT()

## Land use =====================
lcm_share_by_river_grid_year <-
  path_data_clean_lc %>% 
  file.path("grid1km_lcm_shares") %>% 
  dir_ls(glob = "*.pqt") %>% 
  map_dfr(read_parquet) %>% 
  setDT()

#' @Deprecated I didn't end up using DEM bc its not time varying
# ## Elevation and slope ============
# elevation_by_river_grid <-
#   path_data_clean %>%
#   file.path("dem", "river_grid_elevation_slope.pqt") %>%
#   read_parquet()

## Soil agriculture capability classes =============
soil_lca_by_river_grid <-
  path_data_clean_soil %>%
  file.path("river_grid_dom_soil.pqt") %>%
  read_parquet()

## Weather ==============
weather_by_river_grid_year <-
  path_data_clean_weather %>%
  file.path("river_grid_weather_panel.pqt") %>%
  read_parquet() %>%
  setDT()

# Clean data ======================================

# Analysis ========================================

## Merge beaver, hydrometry, and land use shares  =======
river_year_panel_all_data <- 
  river_year_panel_complete %>%
  merge(lcm_share_by_river_grid_year , all = TRUE, by = c("river_id", "year")) %>%
  merge(beaver_by_river_grid_year    , all = TRUE, by = c("river_id", "year")) %>%
  merge(hydrometry_by_river_grid_year, all = TRUE, by = c("river_id", "year")) %>%
  merge(weather_by_river_grid_year   , all = TRUE, by = c("river_id", "year")) %>%
  #merge(elevation_by_river_grid     , all = TRUE, by = "river_id") %>%
  merge(soil_lca_by_river_grid       , all = TRUE, by = "river_id")

## Label periods and groups ===============

# Treatment groups 
river_year_panel_all_data[,
                          treatment_year := first_year_treated(year, beaver_d),
                          by = "river_id"
                          ]

river_year_panel_all_data[,
                          g := fcase(is.na(treatment_year) , 0,
                                     treatment_year == 2012, 1,
                                     treatment_year == 2017, 2,
                                     treatment_year == 2020, 3)
                          ]

# Output ==========================================

river_year_panel_all_data %>%
  write_parquet(
    file.path(path_data_clean, "treatment", "river_grid_year_panel_unfilled.pqt")
  )
