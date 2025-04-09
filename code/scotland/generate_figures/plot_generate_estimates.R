# ---------------------------------------------------------------------------- #
#' 
#' Description: Generate and save plots on estimation results
#' Author: Miriam Gold
#' Date: 9 April 2025
#' Last revised: date, mag
#' Notes: notes
#' 
# ---------------------------------------------------------------------------- #

# Should we re-load the input datasets below? FALSE saves time if not needed
READ_DATA <- FALSE 


# Read in data ====================================

if (READ_DATA) {
  
  plan(multisession, workers = 10)
  est_res_lc1 <-
    path_data_est %>%  
    dir_ls(glob = "*is_land_class_1_*.csv") %>% 
    purrr::set_names(basename) %>%
    future_map_dfr(read_csv, .id = "model")
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
    plot_est_lc1_by_cohort, "est_lc1_by_cohort.pdf", path_output_figures, 9, 9
  ) 

nrow(beavers_fig_args)

## Generate and save plots 
beavers_fig_args %>%
  filter(str_detect(filename, "est_lc1_by_cohort.pdf")) %>% 
  #slice(7) %>%
  pwalk(ggsave_wrapper)

