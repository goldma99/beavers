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
  filter(data_provider == "NatureScot") %>%
  mutate(
    # Assign an "effective" survey year (ie, the year that the survey may be 
    # attributable to, to avoid confusing split year aggregation when presenting 
    # expansion figures)
    effective_survey_year = case_when(
      str_detect(dataset_name, "2012") ~ 2012,
      str_detect(dataset_name, "2017-18") ~ 2017,
      str_detect(dataset_name, "2020-2021") ~ 2020
    )
  ) %>%
  
  # Convert to British National Grid CRS to align with other datasets
  st_as_sf(
    coords = c("longitude_wgs84", "latitude_wgs84"),
    crs = 4326
    ) %>%
  st_transform(27700) %>%
  
  # I drop geometry here, because this dataset kept giving me all sorts of 
  # errors when attempting to save it as .shp, so instead I'm saving it as a 
  # .pqt, with coordinate columns
  mutate(latitude  = st_coordinates(.)[,"Y"],
         longitude = st_coordinates(.)[,"X"]) %>%
  st_drop_geometry()

survey_bbox <-
  scotland_survey_clean %>%
  st_as_sf(
    coords = c("longitude", "latitude"),
    crs = 27700
  ) %>%
  st_bbox() %>%
  st_as_sfc()

# Analysis ========================================



# Output ==========================================

## Survey observations =====
path_data_scotland_survey_clean <-
  path_data_clean_beaver %>%
  file.path("beaver_survey.pqt")

scotland_survey_clean %>%
  write_parquet(path_data_scotland_survey_clean)

## Survey bounding box ====
path_survey_bbox <- 
  path_data_clean_beaver %>%
  file.path("beaver_survey_bbox", "beaver_survey_bbox.shp")

survey_bbox %>%
  write_sf(path_survey_bbox)
