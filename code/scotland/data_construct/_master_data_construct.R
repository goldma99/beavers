# ---------------------------------------------------------------------------- #
#' 
#' Description: All scripts pertaining to constructing custom datasets  
#' Author: Miriam Gold    
#' Date: 3 April 2024
#' Last revised: 19 April 2024, mag
#' Notes: notes
#' 
# ---------------------------------------------------------------------------- #

# Set up ==========================================

SOURCE_SCRIPTS <- FALSE

## Source block-specific custom functions ====
path_code_scotland_data_construct %>%
  file.path("functions") %>%
  source_dir()

# Source individual scripts =====================

if (SOURCE_SCRIPTS) {
  
  ## Construct balanced beaver expansion panel ======================
  path_code_scotland_data_clean %>%
    file.path("data_construct_beaver_expansion.R") %>%
    source()
  
}