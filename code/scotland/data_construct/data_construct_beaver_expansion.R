# ---------------------------------------------------------------------------- #
#' 
#' Description: Create annual panel of beaver expansion using river network and beaver observations in 2012, 2017, and 2020 
#' Author: Miriam Gold
#' Date: 22 Mar 2024
#' Last revised: date, mag
#' Notes: notes
#' 
# ---------------------------------------------------------------------------- #

# Set up ==========================================

## Load packages =====

## File system paths ====

# Read in data ====================================

## Ag parishes ======
ag_parish_in_survey <-
  path_data_clean_parish %>%
  file.path("ag_parish_in_survey") %>%
  read_geography()

## Scotland beaver survey =======

scotland_survey <- 
  path_data_clean_beaver %>%
  file.path("beaver_survey.pqt") %>%
  read_parquet()

## River segments ======
river_link_sf <-
  path_data_clean_river %>%
  file.path("scotland_river_links") %>%
  read_geography()

# Clean data ======================================

## Beaver survey ====
scotland_survey_sf <-
  scotland_survey %>%
  st_as_sf(
    coords = c("longitude", "latitude"),
    crs = 27700
  )

# Analysis ========================================

## 1. Link beaver points to river edges (segments) =====

crosswalk_link_id_index <-
  river_link_sf %>%
  select(link_identifier = id, link_index) %>%
  st_drop_geometry()

### Find the nearest river segment ("link") to each beaver observation point ==== 
scotland_survey_river_join <-
  scotland_survey_sf %>%
  mutate(nearest_link_index = st_nearest_feature(., river_link_sf)) %>%
  left_join(crosswalk_link_id_index, by = c("nearest_link_index" = "link_index"))

links_by_first_year <-
  scotland_survey_river_join %>%
  st_drop_geometry() %>%
  select(link_identifier, nbn_atlas_record_id, start_date_year) %>%
  group_by(link_identifier) %>%
  summarise(first_year = min(start_date_year)) %>%
  left_join(river_link_sf, by = c("link_identifier" = "id")) %>%
  st_as_sf()
  

# Descriptive map showing beaver observations expanding over 
# time and space (note the general pattern of expansion downstream)
ggplot() +
  
  geom_sf(data = ag_parish_in_survey, 
          color = NA, 
          fill = "grey95") +
  geom_sf(data = river_link_sf, 
          color = "grey70") +
  geom_sf(data = links_by_first_year, 
          aes(color = factor(first_year)), 
          linewidth = 1.2) +
  
  scale_color_viridis_d("First Year\nof Beaver Obs") +
  
  theme_minimal() +
  theme(
    text = element_text(family = "cmr")
  )


# # Descriptive stat showing the unbalanced nature of the survey "panel" and the 
# # need to fill in the gaps
# scotland_survey_sf %>%
#   st_drop_geometry() %>%
#   count(start_date_year) %>%
#   ggplot(aes(x = start_date_year, y = n)) +
#   geom_bar(fill = "grey20",
#            width = 0.7,
#            stat = "identity") +
#   geom_text(aes(label = n),
#             vjust = -0.5,
#             family = "cmr",
#             size = 2) +
# 
#   scale_x_continuous(breaks = 2012:2021) +
#   scale_y_continuous(limits = c(0, 30000),
#                      expand = expansion(add = c(0, 0))) +
#   
#   labs(
#     x = "Observation Year",
#     y = NULL,
#     subtitle = "Observation Count"
#   ) +
#   
#   theme_classic() +
#   theme(
#     text = element_text(family = "cmr")
#   )

## 2. determine downstream points =====
