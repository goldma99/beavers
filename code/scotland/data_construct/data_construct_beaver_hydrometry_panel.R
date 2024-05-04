# ---------------------------------------------------------------------------- #
#' 
#' Description: Construct river grid cell panel with hydrometry measurements and 
#'              beaver presence 
#' Author: Miriam Gold
#' Date: 27 April 2024
#' Last revised: date, mag
#' Notes: notes
#' 
# ---------------------------------------------------------------------------- #

# Read in data ====================================

## River grid =======================
river_grid_sf <-
  path_data_clean_river %>%
  file.path("river_grid", "river_grid.shp") %>%
  read_sf()

## Beaver survey ====================
beaver_survey <-
  path_data_clean_beaver %>%
  file.path("beaver_survey.pqt") %>%
  read_parquet()

## Hydrometry station measurements ==========

hydrometry_values <-
  path_data_clean_hydrometry %>%
  file.path("survey_stations_level_ts_values.csv") %>%
  read_csv()

# Clean data ======================================

## Beaver survey ====================
beaver_survey_sf <-
  beaver_survey %>%
  st_as_sf(
    coords = c("longitude", "latitude"),
    crs = 27700
  ) 

## Hydrometry station measurements ==========
hydrometry_values_sf <-
  hydrometry_values %>%
  st_as_sf(
    coords = c("station_longitude", "station_latitude"),
    crs = 4326
  ) %>%
  st_transform(crs = 27700)

# Analysis ========================================

## Beaver-grid panel ============================

grid_year_panel_beaver <-
  beaver_survey_sf %>%
  ## Attach beaver obs to the river grid cell where they occurred
  st_join(river_grid_sf) %>%
  select(nbn_atlas_record_id, year = effective_survey_year, cell_id) %>%
  st_drop_geometry() %>%
  ## Count beaver observations by river grid cell and year
  count(cell_id, year, name = "beaver_count") %>%
  ## Create dummy and log version of the beaver observation variable
  mutate(
    beaver_d = as.numeric(beaver_count > 0),
    beaver_count_log = log(beaver_count)
  ) %>%
  ## Complete panel so there is a row for every possible cell-year combo,
  ## even those with no beaver observations
  complete(
    cell_id = unique(river_grid_sf$cell_id),
    year = 1990:2020,
    fill = list(beaver_count = 0, beaver_d = 0, beaver_count_log = NA)
  ) %>%
  ## Mark each grid cell as either ever-treated (1) or never-treated (0)
  group_by(cell_id) %>%
  mutate(
    ever_treated_beaver = max(beaver_d) 
  ) %>%
  ungroup()



## Hydrometry-grid panel ========================

collapse_values <- function(x, collapse = ",") paste0(unique(x), collapse = collapse)

grid_year_panel_hydrometry <-
  hydrometry_values_sf %>%
  
  mutate(year = year(ts_timestamp)) %>%
  select(station_id, year, ts_value, quality_code) %>%
  ## Attach hydrometry readings to river grid cell where they occurred
  st_join(river_grid_sf, join = st_nearest_feature) %>%
  st_drop_geometry() %>%
  ## Calc mean river level by cell-year
  group_by(cell_id, year) %>%
  summarise(
    level_mean = mean(ts_value, na.rm = TRUE),
    quality_codes = collapse_values(quality_code)
  ) %>%
  ungroup() %>%
  ## Calculate year-to-year changes in river level
  group_by(cell_id) %>%
  mutate(
    level_mean_lag = lag(level_mean),
    level_mean_pct_change = (level_mean - level_mean_lag) / level_mean_lag
  ) %>%
  ungroup()

## Merge beaver and hydrometry panels by grid cell and year ============
grid_year_panel_beaver_hydrometry <-
  inner_join(
    grid_year_panel_beaver,
    grid_year_panel_hydrometry,
    by = c("cell_id", "year")
    ) %>%
  rename(river_cell_id = cell_id)

# Output ==========================================

#' @Use-later
#' Nice little descriptive showing that ever-treated grid cells don't have
#' systematically different river levels than treated (though there does seem to be 
#' a wider spread among never-treated grid cells)
# grid_year_panel_beaver_hydrometry %>%
#   ggplot(aes(x = year, 
#              y = log(level_mean), 
#              group = cell_id,
#              color = fct(as.character(ever_treated_beaver)))) +
#   geom_line(linewidth = 1, alpha = 0.4) +
#   scale_color_brewer("Ever Treated", palette = "Dark2") +
#   
#   theme_minimal() 

## Grid cell-year panel containing beaver density and river level ======
grid_year_panel_beaver_hydrometry %>%
  write_csv(
    file.path(path_data_clean, "treatment", "river_grid_panel_beaver_hydrometry.csv")
  )


