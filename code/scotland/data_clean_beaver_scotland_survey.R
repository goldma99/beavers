# ---------------------------------------------------------------------------- #
#' 
#' Description: Clean data from NatureScot's repeated surveys of Tayside Beavers 
#' Author: Miriam Gold
#' Date: 4 Feb 2024
#' Last revised: date, initials
#' Notes: https://www.nature.scot/professional-advice/protected-areas-and-species/protected-species/protected-species-z-guide/beaver/tayside-beaver-study-group
#' 
# ---------------------------------------------------------------------------- #

# Set up ==========================================

## Load packages ====
library(janitor)
library(lubridate)
library(sf)

## File system paths ====

# Read in data ====================================

scotland_survey <-
  path_data_scotland_survey %>%
  file.path("beaver-scotland-survey.csv") %>%
  read_csv()

# Clean data ======================================

scotland_survey_clean <-
  scotland_survey %>%
  clean_names() %>%
  # Only keep beaver data collected by NatureScot as part of their 3 surveys 
  # on beaver presence in Tayside
  filter(data_provider == "NatureScot")

scotland_survey_sf <-
  scotland_survey_clean %>%
  st_as_sf(
    coords = c("longitude_wgs84", "latitude_wgs84"),
    crs = 4326
    ) %>%
  st_transform(27700) %>%
  mutate(latitude  = st_coordinates(.)[,"Y"],
         longitude = st_coordinates(.)[,"X"]) %>%
  st_drop_geometry()

# Analysis ========================================

survey_bbox <-
  scotland_survey_sf %>%
  st_bbox() %>%
  st_as_sfc()

ggplot() +
  geom_sf(data = scotland_survey_sf, aes(color = factor(start_date_year))) +
  facet_wrap(~dataset_name) +
  theme_minimal()


# Output ==========================================

path_data_scotland_survey_clean <-
  path_data_clean_beaver %>%
  file.path("beaver_survey.pqt")

scotland_survey_sf %>%
  write_parquet(path_data_scotland_survey_clean)

st_delete(path_data_scotland_survey_clean)
