# ---------------------------------------------------------------------------- #
#' 
#' Description: Import and aggregate elevation statistics 
#' Author: Miriam Gold
#' Date: 12 Oct 2024
#' Last revised: date, mag
#' Notes: notes
#' 
# ---------------------------------------------------------------------------- #

# Read in data ====================================

## Elevation data ===============
astgtm_dem_raw <-
  path_data_scotland %>%
  file.path(
    "astgtm", 
    "ASTGTM_NC.003_ASTER_GDEM_DEM_doy2000061_aid0001.tif"
    ) %>%
  rast()

## River grid cell polygons ==========
river_grid_vector <-
  path_data_clean_river %>% 
  file.path("river_grid", "river_grid.shp") %>%
  vect() %>%
  project("epsg:4326")

# Clean data ======================================

## Calculate slope (first derivative of elevation surface) =======
astgtm_dem_slope <- 
  astgtm_dem_raw %>%
  terrain(v = "slope")

## Concatenate elevation and slope data into a single raster object =========
astgtm_dem_join <- c(astgtm_dem_raw, astgtm_dem_slope)

# To reduce compute time, crop raster to river grid bounding box 
river_grid_ext  <- ext(river_grid_vector)
astgtm_dem_crop <- crop(astgtm_dem_join, river_grid_ext)

# Analysis ========================================

## Link elevation and slope data to river grid cells ============
dem_raster_extract <-
  astgtm_dem_crop %>%
  #spatSample(10, as.raster = TRUE) %>%
  extract(river_grid_vector, weights = TRUE) %>%
  setDT()

setnames(
  dem_raster_extract,
  old = c("ID", "ASTGTM_NC.003_ASTER_GDEM_DEM_doy2000061_aid0001"),
  new = c("river_id", "elevation")
)

## Aggregate elevation and slope to river grid cell level ========
river_grid_elevation_slope <-
  dem_raster_extract[,
                     .(
                       mean_elevation = weighted.mean(elevation, weight),
                       mean_slope     = weighted.mean(slope, weight)
                       ),
                     by = river_id
                     ]


# Output ==========================================

## Elevation/slope at river grid cell level ==============
river_grid_elevation_slope %>%
  write_parquet(
    file.path(path_data_clean, "dem", "river_grid_elevation_slope.pqt")
  )

terra::set.names(astgtm_dem_crop, c("elevation", "slope"))

astgtm_dem_crop %>%
  writeRaster(
    file.path(path_data_clean, "dem", "dem_cropped.tif"),
    overwrite = TRUE
    )
