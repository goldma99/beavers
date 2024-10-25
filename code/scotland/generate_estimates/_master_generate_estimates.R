# ---------------------------------------------------------------------------- #
#' 
#' Description: Run DiD regressions estimate beaver impacts on land and enviro
#' Author: Miriam Gold
#' Date: 25 Oct 2024
#' Last revised: date, mag
#' Notes: notes
#' 
# ---------------------------------------------------------------------------- #

# Set up ==========================================

SOURCE_SCRIPTS <- FALSE

## Source block-specific custom functions ====
path_code_scotland_generate_estimates %>%
  file.path("functions") %>%
  source_dir()

# Source individual scripts =====================

if (SOURCE_SCRIPTS) {
  
  ## Main specification ==================
  path_code_scotland_generate_estimates %>%
    file.path("generate_estimates_main.R") %>%
    source()
  
}
