# ---------------------------------------------------------------------------- #
#' 
#' Description: Import and clean rasterized land cover data from UKCEH
#' Author: Miriam Gold
#' Date: 4 May 2024
#' Last revised: date, initials
#' Notes: notes
#' 
# ---------------------------------------------------------------------------- #

# Set up ==========================================

## Load packages ====
library(raster)
library(data.table)
library(terra)

## File system paths ====

#' @Deprecated
# path_data_ukceh <- file.path(path_data_scotland, "ukceh")
# path_data_ukceh_lcm <- file.path(path_data_ukceh, "Land Cover Map 2021 (25m rasterised land parcels, GB)")
# 
# path_data_geo <- file.path(path_data_scotland, "geography")
# 
# path_data_clean_geo <- file.path(path_data_clean, "geography")


# Read in data ====================================

## Scotland map =====
# scotland_sf <-
#   path_data_clean_geo %>%
#   file.path("nuts_scotland", "nuts_scotland.shp") %>%
#   read_sf()

## Define 
path_raster_year_list <-
  path_data_scotland_ukceh %>%
  dir_ls() %>%
  purrr::set_names(~str_extract(.x, "Land Cover Map (\\d{4}) ", group = 1)) %>%
  sort() %>%
  dir_ls(recurse = TRUE, glob = "*.tif$")

#' @Deprecated 
# lcm_raster <-
#   path_data_ukceh_lcm %>%
#   file.path("data", "LCM.tif") %>%
#   raster::brick()
# 
# lcm_colors_lyr <-
#   path_data_ukceh_lcm %>%
#   file.path("supporting-docs", "LCMcolours.lyr")

# Process land cover data ======================================

## Determine the proportion of 1km grid cells that are classified as arable/horticulture
path_raster_year_list %>%
  walk(process_ukceh)

#' @Deprecated
# ## UKCEH Land Cover Class number reference table =====
# ##' Source: `LCM2021ProductDocumentation.pdf` in `supporting-docs/` subdirectory
# ##' of the UKCEH data download bundle
# ##' @Note: I consider to be "agricultural" the following classes:
# ##'   - 3: Arable and Horticulture
# ##'   - 4: Improved Grassland
# lc_class_ref <-
#   tibble(
#     class_no = 1:21,
#     class_desc = c("Broadleaved woodland", 
#                    "Coniferous Woodland",
#                    "Arable and Horticulture",
#                    "Improved Grassland",
#                    "Neutral Grassland",
#                    "Calcereous Grassland",
#                    "Acid grassland",
#                    "Fen, Marsh, and Swamp",
#                    "Heather",
#                    "Heather grassland",
#                    "Bog",
#                    "Inland Rock",
#                    "Saltwater",
#                    "Freshwater",
#                    "Supralittoral Rock",
#                    "Supralittoral Sediment",
#                    "Littoral Rock",
#                    "Littoral sediment",
#                    "Saltmarsh",
#                    "Urban",
#                    "Suburdan")
#     )
# # crop()
# # extract()
# # rasterize()
# lcm_df <-
#   lcm_raster$LCM_1 %>%
#   as.data.frame(xy = TRUE)
# 
# setDT(lcm_df)
# 
# lcm_nonmissing <- lcm_df[!is.na(LCM_1)]
# 
# lcm_ag <- lcm_nonmissing[LCM_1 %in% c(3, 4)]
# 
# lcm_sample <-
#   lcm_ag[1:1000000] %>%
#   as_tibble()
# 
# lcm_nonmissing[1:1000000] %>%
#   ggplot() +
#   geom_tile(aes(x, y, fill = forcats::fct_inseq(as.character(LCM_1)))) +
#   scale_fill_viridis_d() +
#   theme_minimal()
# 
# # Analysis ========================================
# # Load the necessary libraries
# calc_dominant_class <- function(x, na.rm = TRUE, ...) {
#   tbl <- table(x)
#   if (length(tbl) == 0) {
#     NA
#   } else {
#     names(tbl)[which.max(tbl)] %>%
#       as.numeric()
#   }
# }
# 
# lcm_sample <-
#   lcm_raster$LCM_1
#   crop(extent(lcm_raster)/10)
# 
# scotland_sp <-
#   scotland_sf %>%
#   st_make_grid(cellsize = 0.1) %>%
#   st_as_sf() %>%
#   st_filter(scotland_sf) %>%
#   st_transform(27700) %>%
#   rowid_to_column() %>%
#   as("Spatial")
# 
# lcm_scotland_crop <- 
#   lcm_sample %>%
#   extract(
#     scotland_sp, 
#     df = TRUE, 
#     fun = calc_dominant_class, 
#     sp = TRUE
#   )
# 
# g <- RColorBrewer::brewer.pal(4, "Greens")[4]
# 
# lcm_scotland_crop %>% 
#   st_as_sf() %>%
#   left_join(
#     lc_class_ref,
#     by = c("LCM_1" = "class_no")
#   ) %>%
#   mutate(class_desc = fct_reorder(class_desc, LCM_1),
#          class_ag = LCM_1 %in% c(3, 4)) %>%
#   ggplot() +
#   geom_sf(aes(fill = class_ag), color = NA) +
#   geom_sf(data = scotland_sf, linewidth = 1, fill = NA) +
#   scale_fill_manual(
#     values = c(`FALSE` = "grey80",
#                `TRUE` = g),
#     guide = guide_legend(ncol = 1) 
#   ) +
#   #coord_sf(crs = 4326) +
#   theme_minimal()
# 
# # Step 4: Check for intersection with a specific class (e.g., class 4)
# # This will create a new column for each class you want to check
# check_class <- function(x, class) {
#   return(as.integer(class %in% x))
# }
# for (class in 1:21) {
#   class_col_name <- paste0("contains_class_", class)
#   vector_data[[class_col_name]] <- apply(extracted_data[,-1], 1, check_class, class)
# }
# 
# # Now your vector_data has the dominant class and the intersection flags for each class
# 
# # Step 5: Write the updated vector data to a new shapefile
# st_write(vector_data, "path_to_output_vector_file.shp")
# 
# # Output ==========================================