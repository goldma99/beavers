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
  
  ## Import and clean SEPA Hydrometry timeseries data =============== 
  path_code_scotland_data_clean %>%
    file.path("data_clean_hydrometry.R") %>%
    source()
  
}


# Analysis ========================================

# Output ==========================================

