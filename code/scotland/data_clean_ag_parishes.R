# ---------------------------------------------------------------------------- #
#' 
#' Description: Import and clean spatial data on Scotland Ag parish admin units
#' Author: Miriam Gold
#' Date: 4 Feb 2024
#' Last revised: date, initials
#' Notes: notes
#' 
# ---------------------------------------------------------------------------- #

# Set up ==========================================

## Load packages ====
library(sf)

## File system paths ====
path_data_scotland_parish <- file.path(path_data_scotland, "SG_AgriculturalParishes_2016")

# Read in data ====================================
ag_parish_sf <-
  path_data_scotland_parish %>% 
  file.path("SG_AgriculturalParishes_2016", "SG_AgriculturalParishes_2016.shp") %>% 
  read_sf()

# Clean data ======================================

ag_parish_in_survey <-
  ag_parish_sf %>%
  st_filter(survey_bbox)

ggplot() +
  geom_sf(data = ag_parish_in_survey) +
  geom_sf(data = st_jitter(scotland_survey_sf), 
          aes(color = start_date_year))

# Analysis ========================================

# Output ==========================================