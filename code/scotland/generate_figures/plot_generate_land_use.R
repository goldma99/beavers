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
  
  ## Beaver survey points 
  beaver_survey <-
    path_data_clean_beaver %>%
    file.path("beaver_survey.pqt") %>% 
    read_parquet()

  ## land use classification at original resolution 
  lcm_25m_rast_list <-
    path_data_scotland_ukceh %>%
    dir_ls() %>%
    purrr::set_names(~str_extract(.x, "Land Cover Map (\\d{4}) ", group = 1)) %>%
    sort() %>%
    dir_ls(recurse = TRUE, glob = "*.tif$") %>% 
    map(read_ukceh)
  
  ## LCM aggregated to river grid cells
  river_ag_share_y2022 <-
    path_data_clean_lc %>% 
    file.path("river_ag_share", "river_ag_share_y2022.pqt") %>%
    read_parquet()
  
  ## Soil capability classes
  soil_lca_sf <-
    path_data_clean_soil %>%
    file.path("soil_lca", "soil_lca.shp") %>%
    read_sf()
  
  ## River grid shp
  river_grid <-
    path_data_clean_river %>%
    file.path("river_grid", "river_grid.shp") %>%
    read_sf()
  
  ## Raw river course
  river_link_sf <-
    path_data_clean_river %>%
    file.path(
      "scotland_river_links",
      "scotland_river_links.shp"
    )  %>%
    vect()
  
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
    plot_lcm_example_area, "lcm_example_area.pdf", path_output_figures, 10, 7,
    plot_lcm_agg_river_grid, "lcm_agg_river_grid.pdf", path_output_figures, 12, 7,
    #plot_outcome_pretrends, "outcome_pretrends.pdf", path_output_figures, 12, 7,
    plot_outcome_pretrends, "outcome_pretrends.png", path_output_figures, 12, 7,
    #plot_soil_lca_map, "soil_lca_map.pdf", path_output_figures, 12, 7,
    plot_soil_lca_map, "soil_lca_map.png", path_output_figures, 8, 7,
    plot_raw_spaghetti_ag_share_g2017, "raw_spaghetti_ag_share_g2017.pdf", path_output_figures, 12, 7,
    plot_balance_by_cohort, "balance_by_cohort.pdf", path_output_figures, 14, 7,
    plot_lcm_25m_time_series, "lcm_25m_time_series.png", path_output_figures, 12, 5
    ) 

nrow(beavers_fig_args)

## Generate and save plots 
beavers_fig_args %>%
  filter(str_detect(filename, "lcm_25m_time_series")) %>% 
    #slice(7) %>%
    pwalk(ggsave_wrapper)

