# ---------------------------------------------------------------------------- #
#' 
#' Description: Construct river grid cell panel with hydrometry measurements and 
#'              beaver presence 
#' Author: Miriam Gold
#' Date: 27 April 2024
#' Last revised: 4 April 2025, mag
#' Notes: notes
#' 
# ---------------------------------------------------------------------------- #

# Read in data ====================================

## River grid =======================
river_grid_sf <-
  path_data_clean_river %>%
  file.path("river_grid", "river_grid.shp") %>%
  read_sf()

## River measurements =================
hydrometry_ts <-
  path_data_hydrometry %>%
  file.path("survey_stations_ts_values.parquet") %>%
  read_parquet() %>%
  setDT()

# Clean data ======================================

## River grid ===================
river_grid_sf_clean <- 
  river_grid_sf %>%
  select(river_id)

### Link hydrometry stations to river grid cells =======
hydrometry_river_join <-
  hydrometry_ts %>%
  distinct(station_id, station_longitude, station_latitude) %>%
  st_as_sf(crs = 4326, coords = c("station_longitude", "station_latitude")) %>%
  st_transform(27700) %>%
  st_join(river_grid_sf_clean) %>%
  st_drop_geometry() %>%
  setDT()

hydrometry_ts_clean <-
  hydrometry_ts[, .(ts_timestamp, 
                    ts_value,
                    ts_shortname,
                    stationparameter_name,
                    quality_code,
                    station_id)
  ][,
    `:=`(year = year(ts_timestamp),
         month = month(ts_timestamp),
         ym = as_date(ts_timestamp),
         param = str_to_lower(stationparameter_name),
         ts_value = as.numeric(ts_value))
  ][
    year %in% 1990:2022
  ][,
    ts_name := str_to_lower(str_remove(ts_shortname, "^H"))
  ][,
    c("freq", "measure") := tstrsplit(ts_name, "\\.")
  ][]

hydrometry_by_river_grid_year <-
  c("groundwaterlevel", "flow", "level") %>% 
  map(
    ~panel_hydrometry(hydrometry_ts_clean, .x)
  ) %>% 
  reduce(full_join, by =  c("station_id", "year")) %>% 
  left_join(
    hydrometry_river_join,
    by = "station_id"
  ) %>%
  group_by(river_id, year) %>%
  summarise(
    across(
      ends_with("_mean"),
      ~ ifelse(all(is.na(.x)), NA, mean(.x, na.rm = TRUE))
    ),
    across(
      ends_with("_max"),
      ~ ifelse(all(is.na(.x)), NA, max(.x, na.rm = TRUE))
    )
  )

# Output =================================

## Grid cell-year panel containing beaver density and river level ======
hydrometry_by_river_grid_year %>%
  write_parquet(
    file.path(path_data_clean_hydrometry, "hydrometry_by_river_grid_year.pqt")
  )


