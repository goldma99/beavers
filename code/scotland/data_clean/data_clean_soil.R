# ---------------------------------------------------------------------------- #
#' 
#' Description: Clean maps of soil ag capability from Hutton Institute
#' Author: Miriam Gold
#' Date: 22 Oct 2024
#' Last revised: date, mag
#' Notes: notes
#' 
# ---------------------------------------------------------------------------- #

# Set up ==========================================
sf::sf_use_s2(FALSE)

## Load packages ====
library(leaflet)
## File system paths ====

# Read in data ====================================

## Soil class code reference table (same for 250k and 50k scale maps) ====
soil_lca_ref <-
  path_data_scotland_soil %>%
  file.path("Hutton_LCA250K_OpenData", "LCA_description_of_codes.xls") %>%
  readxl::read_xls()

## 1:50k scale map (high res, partial cover) ====
soil_lca_50k_raw <-
  path_data_scotland_soil %>%
  file.path("Hutton_LCA50K_OpenData", "LCA_50K.shp") %>%
  sf::read_sf()

## 1:250k scale map (low res, full cover) ====
soil_lca_250k_raw <-
  path_data_scotland_soil %>%
  file.path("Hutton_LCA250K_OpenData", "LCA_250K.shp") %>%
  sf::read_sf()

# Clean data ======================================

## Define ranked factor of soil classes (A is best for ag, M is worst, N is unusable) 
soil_lca_ref_clean <-
  soil_lca_ref %>%
  clean_names() %>%
    select(
      lccode = capability_class
    ) %>%
  mutate(
    lccode_fct = LETTERS[row_number()],
    lccode_fct = if_else(lccode_fct %in% c("N", "O", "P"), "N", lccode_fct),
    lccode_fct = forcats::fct_inorder(lccode_fct),
    lccode_int = as.integer(lccode_fct),
    lccode_maj = case_when(
      trunc(lccode) %in% 1:4 ~ "AC",
      trunc(lccode) %in% 5:7 ~ "IGRG",
      TRUE ~ "NAG"
      ),
    lccode_desc = case_when(
      lccode_maj == "AC" ~ "Arable Cropping",
      lccode_maj == "IGRG" ~ "Improved Grassland and Rough Grazings",
      lccode_maj == "NAG" ~ "Non Agricultural (Built, Water, Unmapped)"
      )
  )

## Fill in missing areas of the 50k map with the 250k low res map
soil_lca_250k_clean <-
  soil_lca_250k_raw %>%
  st_transform(27700)

soil_lca_50k_mainland <-
  soil_lca_50k_raw %>%
  summarise() %>%
  st_cast("POLYGON") %>%
  # Extract only mainland polygon
  slice(1)

soil_lca_250k_diff <- 
  soil_lca_250k_clean %>%
  st_difference(soil_lca_50k_mainland)

soil_lca_50k_250k_bind <-
  soil_lca_50k_raw %>%
  select(LCCODE, Scale) %>%
  bind_rows(
    select(soil_lca_250k_diff, LCCODE, Scale)
    )

soil_lca_full_cover_clean <-
  soil_lca_full_cover %>%
  clean_names() %>%
  left_join(
    soil_lca_ref_clean,
    by = "lccode"
    ) %>%
  # Ensure there are no overlapping bits of thr 250k map left on the east coast
  st_difference()

# Output ==========================================
soil_lca_full_cover_clean %>%
  write_sf(
    file.path(path_data_clean_soil, "soil_lca", "soil_lca.shp")
  )
