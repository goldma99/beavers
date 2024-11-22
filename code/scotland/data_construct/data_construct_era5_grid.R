# ---------------------------------------------------------------------------- #
#' 
#' Description: Assign ERA5 annual values to landscape grid cells
#' Author: Miriam Gold
#' Date: 21 Nov 2024
#' Last revised: 21 Nov 2024, mag
#' Notes: notes
#' 
# ---------------------------------------------------------------------------- #

# Set up ==========================================

## Load packages ====

## File system paths ==== %>%

# Read in data ====================================

## Weather data =============
era5_tpv_annual <-
  file.path("H:/beavers_scotland", "era5_clean", "yearly", "era5_tpv_annual.parquet") %>%
  read_parquet()

## Landscape grid ========
river_grid <-
  path_data_clean_river %>%
  file.path("river_grid", "river_grid.shp") %>%
  read_sf()

## Scotland ===========
scotland_sf <- 
  path_data_clean %>%
  file.path("geography", "nuts_scotland", "nuts_scotland.shp") %>%
  read_sf()

# Clean data ======================================
era5_grid <-
  era5_tpv_annual %>%
  distinct(cell_id) %>%
  mutate(
    lon = str_extract(cell_id, "^(.*),", group = 1),
    lat = str_extract(cell_id, ",(.*)$", group = 1),
    across(c(lon, lat), as.numeric)
  ) %>%
  st_as_sf(
    crs = 4326,
    coords = c("lon", "lat")
  ) %>%
  # Convert geometry from cell centroids to cell polygons to allow for overlap weighting 
  mutate(
    cell_polygon = 
      st_as_sfc(
        map(
          geometry,
          ~make_cell_from_centroid(.x, 0.10)
        ),
        crs = 4326
      )
  ) %>%
  st_set_geometry("cell_polygon") %>%
  select(!geometry) %>%
  rename(geometry = cell_polygon) %>%
  st_transform(27700) %>%
  st_filter(river_grid)

# Analysis ========================================

# Output ==========================================
river_era5_weights <-
  river_grid %>%
  mutate(river_cell_area = st_area(.)) %>%
  st_set_agr("constant") %>%
  st_intersection(st_set_agr(era5_grid, "constant")) %>%
  mutate(
    overlap_area = st_area(.),
    weight = overlap_area / river_cell_area,
    weight = drop_units(weight)
    ) %>% 
  st_drop_geometry() %>%
  select(river_id, cell_id, weight)

river_weather_join <-
  river_era5_weights %>%
  left_join(
    era5_tpv_annual,
    by = "cell_id",
    relationship = "many-to-many"
    ) %>%
  setDT()

river_weather_panel <-
  river_weather_join[,
                     .(
                       tp_mean = weighted.mean(tp, weight, na.rm = TRUE),
                       t2m_mean = weighted.mean(t2m, weight, na.rm = TRUE)
                       ),
                     by = .(river_id, year)
                     ]

river_weather_panel %>%
  write_parquet(
    file.path(path_data_clean, "weather", "river_grid_weather_panel.pqt")
  )
