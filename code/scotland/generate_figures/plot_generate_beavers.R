# ---------------------------------------------------------------------------- #
#' 
#' Description: Generate and save plots concerning beaver expansion in Scotland
#' Author: Miriam Gold
#' Date: 1 April 2024
#' Last revised: date, mag
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
    file.path("ag_parish_in_survey.shp") %>%
    read_sf()
}
# Plot generation ========================================

source_dir(path_code_scotland_fn_plot)

## Collect figure generation elements, where each row is a figure and each
## column is an argument that will be passed to ggsave_wrapper() 
beavers_fig_args <-
  tribble(
    ~plot_fn, ~filename, ~path, ~width, ~height,
    plot_beaver_parish_expansion, "beaver_parish_expansion.pdf", path_figures, 12, 7,
    ) 

## Generate and save plots 
beavers_fig_args %>%
    #slice() %>%
    pwalk(ggsave_wrapper)