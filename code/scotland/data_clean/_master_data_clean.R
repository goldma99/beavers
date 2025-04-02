# ---------------------------------------------------------------------------- #
#' 
#' Description: All scripts pertaining to cleaning and saving raw data
#' Author: Miriam Gold    
#' Date: 3 April 2024
#' Last revised: 13 April 2024, initials
#' Notes: notes
#' 
# ---------------------------------------------------------------------------- #

# Set up ==========================================

SOURCE_SCRIPTS <- FALSE

## Source block-specific custom functions ====
path_code_scotland_data_clean %>%
  file.path("functions") %>%
  source_dir()

# Source individual scripts =====================

if (SOURCE_SCRIPTS) {
  
  ## Clean geographical data ===================== 
  path_code_scotland_data_clean %>%
    file.path("data_clean_geography.R") %>%
    source()
  
  ## Clean soil classification data ===================== 
  path_code_scotland_data_clean %>%
    file.path("data_clean_soil.R") %>%
    source()
  
  ## Clean beaver survey data ==================
  path_code_scotland_data_clean %>%
    file.path("data_clean_beaver_scotland_survey.R") %>%
    source()
  
  ## Clean land cover classification data ====================
  
  path_code_scotland_data_clean %>% 
    file.path("data_clean_lcm_agg_class_codes.R") %>% 
    source()
  
  path_code_scotland_data_clean %>% 
    file.path("data_clean_land_cover.R") %>% 
    source()
  
  ## Clean agriculture parish admin region data ==================
  path_code_scotland_data_clean %>%
    file.path("data_clean_ag_parishes.R") %>%
    source()
  
  ## Clean river network data ==================
  path_code_scotland_data_clean %>%
    file.path("data_clean_river_network.R") %>%
    source()
  
  ## Import and clean SEPA Hydrometry timeseries data =============== 
  path_code_scotland_data_clean %>%
    file.path("data_clean_hydrometry.R") %>%
    source()
  
}


# Analysis ========================================

# Output ==========================================

