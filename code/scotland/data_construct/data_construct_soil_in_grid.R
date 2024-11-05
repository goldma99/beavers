# ---------------------------------------------------------------------------- #
#' 
#' Description: Assign 1km grid cells to a soil class
#' Author: Miriam Gold
#' Date: 5 Nov 2024 /||Election Day||\
#' Last revised: date, initials
#' Notes: Soil class comes from the soil agriculture capatibility classes from
#' Hutton Institute maps 
#' 
# ---------------------------------------------------------------------------- #

# Set up ==========================================

## Load packages ====

## File system paths ====

# Read in data ====================================

## Soil capability classes ========================
soil_lca_sf <-
  path_data_clean_soil %>%
  file.path("soil_lca", "soil_lca.shp") %>%
  read_sf()

## Landscape grid =================================
river_grid_sf <-
  path_data_clean_river %>%
  file.path("river_grid", "river_grid.shp") %>%
  read_sf()

# Clean data ======================================

#' @Note: set attributes as constant across geoms to avoid stopping errors
st_agr(river_grid_sf) <- "constant"
st_agr(soil_lca_sf)   <- "constant"

## Grid cell area will be the denominator in the soil share calc below
river_grid_clean <-
  river_grid_sf %>%
  mutate(river_cell_area = st_area(.)) %>%
  st_set_agr("constant")

soil_lca_in_sample <-
  soil_lca_sf %>%
  st_filter(river_grid_clean) %>%
  st_crop(st_bbox(river_grid_clean)) %>%
  st_set_agr("constant")

# Analysis ========================================

## Create intersection geometries of soil map units by landscape cells 
grid_soil_intersection <-
  soil_lca_in_sample %>%
  st_intersection(river_grid_clean) %>%
  # Calc area of the soil intersection geometry inside each cell
  #' @Note: _mu_ = "map unit" (std term for spatial units in soil maps)
  mutate(soil_mu_area = st_area(.)) %>%
  st_drop_geometry() %>%
  setDT()

## Calculate soil class shares and determine dominant soil type
grid_soil_share_long <-
  grid_soil_intersection[,
                         lccd_mj_share := soil_mu_area / river_cell_area
                         ][,
                           .(lccd_mj_share = drop_units(sum(lccd_mj_share))),
                           by = .(river_id, lccd_mj)
                           ][,
                             lccd_mj_dom := lccd_mj[which.max(lccd_mj_share)],
                             by = .(river_id)
                           ][]

## Pivot wide to make a grid-cell-level dataset
grid_soil_share_wide <-
  grid_soil_share_long %>%
  pivot_wider(
    id_cols = c(river_id, lccd_mj_dom),
    names_from = lccd_mj,
    values_from = lccd_mj_share,
    names_glue = "soil_share_{str_to_lower(lccd_mj)}",
    values_fill = 0
  )




# Output ==========================================
grid_soil_share_wide %>%
  write_parquet(
    file.path(path_data_clean_soil, "river_grid_dom_soil.pqt")
  )
