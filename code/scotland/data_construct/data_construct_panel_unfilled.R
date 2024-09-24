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
  setDT() %>%
  setkey(river_id, year)

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
  merge(hydrometry_by_river_grid_year, all = TRUE, by = c("river_id", "year"))

# Output ==========================================

river_year_panel_all_data %>%
  write_parquet(
    file.path(path_data_clean, "treatment", "river_grid_year_panel_unfilled.pqt")
  )

river_year_panel_all_data[,
                          ag_share_fill := approx(year, ag_share, n = .N)$y,
                          by = river_id
                          ][,
                            ag_share_fill := pmax(ag_share_fill, 0)
                            ][,
                              ag_share_fill := pmin(ag_share_fill, 1)
                              ][,
                                is_ag_share_fill := if_else(is.na(ag_share), "Interpolated", "Data")
                              ]

plot_ag_share_fill <- function(data, id) {
  
  message("Plotting river grid cell ", id)
  
  data[river_id == id] %>%
    
    ggplot(
      aes(year, ag_share_fill, shape = is_ag_share_fill, color = is_ag_share_fill)
    ) +
    
    geom_point(size = 3) +
    
    scale_color_manual(values = c(Interpolated = "#90A4AE", Data = "#D84315")) +
    scale_shape_manual(values = c(Interpolated = 16       , Data = 17)) +
    scale_x_continuous(breaks = seq(1990, 2022, by = 1)) +
    scale_y_continuous(limits = c(0, 1), labels = scales::label_percent()) +
    
    labs(
      x = NULL,
      y = NULL,
      subtitle = "% Land in Agricultural Use",
      color = NULL,
      shape = NULL
    ) +
    
    theme_classic() +
    theme(
      text = element_text(size = 19),
      axis.text.x = element_text(size = 12, angle = 30, hjust = 1)
    )
  
  ggsave(filename = glue("ag_share_fill_id{id}.png"),
         path = file.path(path_output_figures, "ag_share_fill"),
         width = 12, height = 7, units = "in")
}

river_year_panel_all_data %>%
  distinct(river_id) %>%
  #slice(1:3) %>%
  pull() %>%
  walk(~plot_ag_share_fill(river_year_panel_all_data, .x))


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