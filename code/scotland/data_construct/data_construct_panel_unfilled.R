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
  file.path("survey_stations_ts_values.parquet") %>%
  read_parquet() %>%
  setDT()

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

## Soil agriculture capability classes =============
soil_lca_by_river_grid <-
  path_data_clean_soil %>%
  file.path("river_grid_dom_soil.pqt") %>%
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

hydrometry_ts_gw <- hydrometry_ts_clean[param == "groundwaterlevel"]  
hydrometry_ts_fl <- hydrometry_ts_clean[param == "flow"]
hydrometry_ts_lv <- hydrometry_ts_clean[param == "level"] 

hydrometry_ts_lv_wide_month <-
  dcast(
    hydrometry_ts_lv,
    station_id + year + month ~ param + measure,
    value.var = "ts_value"
    )

hydrometry_ts_lv_wide <-
  hydrometry_ts_lv_wide_month[
    !is.na(level_max) & !is.na(level_mean),
    .(level_max = max(level_max, na.rm = TRUE),
      level_mean = mean(level_mean, na.rm = TRUE)),
    by = .(station_id, year)
    ]

hydrometry_ts_gw_wide <-
  hydrometry_ts_gw %>%
  dcast(
    station_id + year ~ param + measure,
    value.var = "ts_value"
  )

hydrometry_ts_fl_day_wide <-
  hydrometry_ts_fl[freq == "day"] %>%
  dcast(
    station_id + ym ~ param + measure,
    value.var = "ts_value"
    )

hydrometry_ts_fl_max <-
  hydrometry_ts_fl[
    freq == "year", 
    .(station_id, year, flow_max = ts_value)
    ]

hydrometry_ts_fl_mean <-
  hydrometry_ts_fl_day_wide[,
                            year := year(ym)
                            ][,
                              .(flow_mean = mean(as.numeric(flow_mean), na.rm = TRUE)),
                              by = .(station_id, year)
                              ]
hydrometry_ts_fl_wide <-
  merge(
    hydrometry_ts_fl_max, 
    hydrometry_ts_fl_mean, 
    all = TRUE, 
    by = c("station_id", "year")
  )


hydrometry_by_river_grid_year <-
  hydrometry_ts_fl_wide %>%
  merge(hydrometry_ts_gw_wide, all = TRUE, by = c("station_id", "year")) %>%
  merge(hydrometry_ts_lv_wide, all = TRUE, by = c("station_id", "year")) %>%
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
  

# Analysis ========================================

## Merge beaver, hydrometry, and ag_share 
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
 
river_year_panel_all_data <- 
  river_year_panel_complete %>%
  merge(ag_share_by_river_grid_year  , all = TRUE, by = c("river_id", "year")) %>%
  merge(beaver_by_river_grid_year    , all = TRUE, by = c("river_id", "year")) %>%
  merge(hydrometry_by_river_grid_year, all = TRUE, by = c("river_id", "year")) %>%
  merge(elevation_by_river_grid      , all = TRUE, by = "river_id") %>%
  merge(soil_lca_by_river_grid       , all = TRUE, by = "river_id")

## Label periods and groups ===============

# Pre- and post-treatment periods
river_year_panel_all_data[,
                          `:=`(t_overall = fcase(year %in% 1990:2000, 0,
                                                 year %in% 2020:2022, 1),
                               t_g1      = fcase(year %in% 1990:2000, 0,
                                                 year %in% 2012:2022, 1),
                               t_g2      = fcase(year %in% 1990:2000, 0,
                                                 year %in% 2017:2022, 1))
                          ]

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
