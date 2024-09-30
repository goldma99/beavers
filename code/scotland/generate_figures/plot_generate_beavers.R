# ---------------------------------------------------------------------------- #
#' 
#' Description: Generate and save plots concerning beaver expansion in Scotland
#' Author: Miriam Gold
#' Date: 1 April 2024
#' Last revised: 28 Sept 2024, mag
#' Notes: notes
#' 
# ---------------------------------------------------------------------------- #


# Should we re-load the input datasets below? FALSE saves time if not needed
READ_DATA <- FALSE 

# Read in data ====================================

if (READ_DATA) {
  ## Beaver survey ===========
  beaver_survey <-
    path_data_clean_beaver %>%
    file.path("beaver_survey.pqt") %>%
    read_parquet()
  
  beaver_survey_sf <-
    beaver_survey %>%
    st_as_sf(
      coords = c("longitude", "latitude"),
      crs = 27700
    )
  
  ## Agricultural parishes ==============
  ag_parish_in_survey <- 
    path_data_clean_parish %>%
    file.path("ag_parish_in_survey", "ag_parish_in_survey.shp") %>%
    read_sf()
  
  ## River grid shp
  river_grid <-
    path_data_clean_river %>%
    file.path("river_grid", "river_grid.shp") %>%
    read_sf()
  
  ## Panel
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
    #plot_beaver_parish_expansion, "beaver_parish_expansion.pdf", path_output_figures, 12, 7,
    plot_beaver_first_year_treated, "beaver_first_year_treated.pdf", path_output_figures, 10, 7
    ) 

## Generate and save plots 
beavers_fig_args %>%
    #slice() %>%
   pwalk(ggsave_wrapper)