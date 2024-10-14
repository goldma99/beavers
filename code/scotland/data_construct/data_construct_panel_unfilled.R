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

## River levels =================
hydrometry_ts <-
  path_data_clean_hydrometry %>%
  file.path("survey_stations_level_ts_values.csv") %>%
  read_csv()

## Land use =====================
ag_share_by_river_grid_year <-
  path_data_clean_lc %>%
  file.path("river_ag_share") %>%
  dir_ls(glob = "*.pqt") %>%
  map_dfr(read_parquet) %>%
  setDT()

## Elevation and slope ============
elevation_by_river_grid <-
  path_data_clean %>%
  file.path("dem", "river_grid_elevation_slope.pqt") %>%
  read_parquet()

# Clean data ======================================

## River grid ===================
river_grid_sf_clean <- 
  river_grid_sf %>%
  select(river_id)

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

## River levels =================

### Link hydrometry stations to river grid cells 
hydrometry_river_join <-
  hydrometry_ts %>%
  distinct(station_id, station_longitude, station_latitude) %>%
  st_as_sf(crs = 4326, coords = c("station_longitude", "station_latitude")) %>%
  st_transform(27700) %>%
  st_join(river_grid_sf_clean) %>%
  st_drop_geometry()

hydrometry_by_river_grid_year <-
  hydrometry_ts %>%
  select(timestamp, 
         river_level = ts_value,
         quality_code,
         station_id) %>%
  mutate(year = year(timestamp),
         month = month(timestamp),
         ym = as_date(floor_date(timestamp, "month"))) %>%
  # This is when the land use data starts
  filter(year %in% 1990:2022) %>%
  left_join(hydrometry_river_join, 
            by = "station_id",
            relationship = "many-to-many") %>%
  group_by(river_id, year) %>%
  summarise(
    river_level_mean = mean(river_level, na.rm = TRUE)
  ) %>%
  ungroup() %>%
  setDT() %>%
  setkey(river_id, year)

# Analysis ========================================

## Merge beaver, hydrometry, and ag_share 
river_year_panel_complete <-
  river_grid_sf_clean %>%
  st_drop_geometry() %>%
  expand(river_id, year = 1990:2022) %>%
  setDT() %>%
  setkey(river_id, year)
 
river_year_panel_all_data <- 
  river_year_panel_complete %>%
  merge(ag_share_by_river_grid_year  , all = TRUE, by = c("river_id", "year")) %>%
  merge(beaver_by_river_grid_year    , all = TRUE, by = c("river_id", "year")) %>%
  merge(hydrometry_by_river_grid_year, all = TRUE, by = c("river_id", "year")) %>%
  merge(elevation_by_river_grid      , all = TRUE, by = "river_id")

# Output ==========================================

river_year_panel_all_data %>%
  write_parquet(
    file.path(path_data_clean, "treatment", "river_grid_year_panel_unfilled.pqt")
  )

#' @EDA
#' # Only covers 311 river grid cells. 
#' #' @TODO: consider changing this join from intersects to within a certain 
#' #' distance, to give more river grid cells measurements
#' #' @Note: balanced in time but not in space
#' hydrometry_by_river_grid_year %>%
#'   ggplot(aes(year, river_id, fill = river_level_mean)) +
#'   geom_tile() +
#'   scale_fill_viridis_c(trans = "log10", option = "inferno", labels = scales::label_comma())
#' 
#' ## Land use =====================
#' #' @Note: balanced in space but not in time
#' river_grid_ag_share %>%
#'   ggplot(aes(year, river_id, fill = ag_share)) +
#'   geom_tile() +
#'   scale_fill_viridis_c(option = "inferno", direction = 1)
#' 
#' #' @Note: balanced in space (implicitly), but not time
#' #' "implicitly" because only positive sighting are reported in the data
#' beaver_by_river_grid_year %>%
#'   ggplot(aes(effective_survey_year, river_id, fill = n)) +
#'   geom_tile() +
#'   scale_fill_viridis_c(option = "inferno", trans = "log10")