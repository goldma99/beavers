# ---------------------------------------------------------------------------- #
#' 
#' Description: Generate and save descriptive plots  
#' Author: Miriam Gold
#' Date: 14 Mar 2025
#' Last revised: date, initials
#' Notes: By 'descriptive,' I'm referring to data that is not apart of my 
#'        generated database
#' 
# ---------------------------------------------------------------------------- #

# Should we re-load the input datasets below? FALSE saves time if not needed
READ_DATA <- FALSE

# Read in data ====================================

if (READ_DATA) {
  
  ## Scotland =======================
  scotland_sf <-
    path_data_clean_geography %>% 
    file.path("nuts_scotland", "nuts_scotland.shp") %>% 
    read_sf()
  
  ## Landscape grid =======================
  river_grid_sf <-
    path_data_clean_river %>%
    file.path("river_grid", "river_grid.shp") %>%
    read_sf()
  
  ## ERA5 grid ==================================
  era5_grid_sf <-
    path_data_clean_weather %>% 
    file.path("era5_grid", "era5_grid.shp") %>% 
    read_sf()
  
  ## Hydrometry station locations ============================
  hydrometry_metadata_sf <-
    path_data_hydrometry %>%
    file.path("survey_stations_ts_metadata.csv") %>%
    read_csv() %>% 
    st_as_sf(
      coords = c("station_longitude", "station_latitude"),
      crs = 4326
    )
  
  ## Animals translocations ========================================
  animal_transloc_raw <- 
    path_data_clean |>
    file.path(
      "descriptive",
      "query_20250314.csv"
    ) |>
    read_csv()
  
  ## Plant translocations ========================================
  #' @Note: Digitized from https://doi.org/10.1007%2Fs10531-025-03013-0, 
  #'        Fig 1d, using https://plotdigitizer.com/app
  #' @Source: Godefroid et al. (2025)        
  plant_transloc_raw <-
    path_data_clean |>
    file.path(
      "descriptive",
      "plant_transloc_by_decade_digitized.csv"
    ) |>
    read_csv()
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
    plot_transloc_animal, "plot_transloc_animal.pdf", path_output_figures, 12, 7,
    plot_transloc_plant , "plot_transloc_plant.pdf" , path_output_figures, 12, 7,
    plot_beaver_territory_change, "beaver_territory_change.pdf", path_output_figures, 12, 7,
    plot_treatment_periods, "treatment_periods.pdf", path_output_figures, 11, 2.5,
    plot_hydrometry_stations_sample, "hydrometry_stations_sample.pdf", path_output_figures, 12, 7,
    plot_era5_grid, "era5_grid.pdf", path_output_figures, 12, 7
  ) 

nrow(beavers_fig_args)

## Generate and save plots 
beavers_fig_args %>%
  filter(str_detect(filename, "era5_grid.pdf")) %>% 
  #slice(7) %>%
  pwalk(ggsave_wrapper)

