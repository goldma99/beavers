# ---------------------------------------------------------------------------- #
#' 
#' Description: Import and clean spatial data on Scotland Ag parish admin units
#' Author: Miriam Gold
#' Date: 4 Feb 2024
#' Last revised: date, initials
#' Notes: notes
#' 
# ---------------------------------------------------------------------------- #

## File system paths ====


# Read in data ====================================
ag_parish_sf <-
  path_data_scotland_parish %>% 
  file.path("SG_AgriculturalParishes_2016", "SG_AgriculturalParishes_2016.shp") %>% 
  read_sf()

beaver_survey_bbox <- 
  path_data_clean_beaver %>%
  file.path("beaver_survey_bbox", "beaver_survey_bbox.shp") %>%
  read_sf() %>%
  st_as_sfc()

# Clean data ======================================

ag_parish_in_survey <-
  ag_parish_sf %>%
  clean_names() %>%
  select(!c(shape_leng, shape_area)) %>%
  st_filter(beaver_survey_bbox)

# Output ==========================================
path_data_clean_parish_in_survey <-
  path_data_clean_parish %>%
  file.path("ag_parish_in_survey.shp")

ag_parish_in_survey %>%
  write_sf(path_data_clean_parish_in_survey)

path_data_clean_parish_in_survey %>%
  read_sf()
