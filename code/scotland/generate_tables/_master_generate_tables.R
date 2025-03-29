# ---------------------------------------------------------------------------- #
#' 
#' Description: Data importing, cleaning, and analysis related to beaver 
#' presence in Scotland
#' Author: Miriam Gold
#' Date: 4 Feb 2024
#' Last revised: date, mag
#' Notes: notes
#' 
# ---------------------------------------------------------------------------- #

SOURCE_SCRIPTS <- FALSE

## Source block-specific custom functions ====
path_code_scotland_generate_tables %>%
  file.path("functions") %>%
  source_dir()

# Reset working directory to top level
setwd(path_code_scotland_generate_tables)

# Source individual scripts =====================

if (SOURCE_SCRIPTS) {
  
  ## Descriptive plots ========================
  path_code_scotland_generate_tables %>%
    file.path("generate_tables_balance.R") %>%
    source()
  
}