# ---------------------------------------------------------------------------- #
#' 
#' Description: Generate and save plots on Scotland LCM land use maps
#' Author: Miriam Gold
#' Date: 28 Sept 2024
#' Last revised: date, mag
#' Notes: notes
#' 
# ---------------------------------------------------------------------------- #

# Should we re-load the input datasets below? FALSE saves time if not needed
READ_DATA <- FALSE 

# Read in data ====================================

if (READ_DATA) {
  
  ## Raw land use raster in study area
  lcm_crop_to_study_y2022 <-
    path_data_clean_lc %>% 
    file.path("lcm_crop_to_study", "lcm_crop_to_study_y2022.tif") %>%
    terra::rast()
  
  ## LCM aggregated to river grid cells
  river_ag_share_y2022 <-
    path_data_clean_lc %>% 
    file.path("river_ag_share", "river_ag_share_y2022.pqt") %>%
    read_parquet()
  
  ## River grid shp
  river_grid <-
    path_data_clean_river %>%
    file.path("river_grid", "river_grid.shp") %>%
    read_sf()
  
  ## Ag parishes
  ag_parish_in_survey <-
    path_data_clean_parish %>%
    file.path("ag_parish_in_survey", "ag_parish_in_survey.shp") %>%
    read_sf()
  
  ## Scotland area map
  nuts_scotland <- 
    path_data_clean %>%
    file.path("geography", "nuts_scotland", "nuts_scotland.shp") %>%
    read_sf()
  
  ## Panel: unfilled 
  river_grid_year_panel_unfilled <-
    path_data_clean %>%
    file.path(
      "treatment", 
      "river_grid_year_panel_unfilled.pqt"
    ) %>%
    read_parquet()
  
  ## Panel: filled
  river_grid_year_panel_filled <-
    path_data_clean %>%
    file.path("treatment", "river_grid_year_panel_filled.pqt") %>%
    read_parquet() %>%
    setDT()
  
}

# Plot generation ========================================

## Make sure plotting functions are up-to-date ====
path_code_scotland_generate_figures %>%
  file.path("plotting_functions") %>%
  source_dir()

## Collect figure generation elements, where each row is a figure and each
## column is an argument that will be passed to ggsave_wrapper() 
beavers_fig_args <-
  tribble(
    ~plot_fn, ~filename, ~path, ~width, ~height,
    plot_study_area, "study_area.pdf", path_output_figures, 7, 10,
    plot_lcm_in_study_area, "lcm_in_study_area.png", path_output_figures, 7, 7,
    plot_lcm_agg_river_grid, "lcm_agg_river_grid.pdf", path_output_figures, 12, 7,
    plot_outcome_pretrends, "outcome_pretrends.pdf", path_output_figures, 9, 7,
    plot_outcome_pretrends, "outcome_pretrends.png", path_output_figures, 9, 7
    ) 

## Generate and save plots 
beavers_fig_args %>%
    slice(3) %>%
    pwalk(ggsave_wrapper)
