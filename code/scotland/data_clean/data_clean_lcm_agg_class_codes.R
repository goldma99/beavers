# ---------------------------------------------------------------------------- #
#' 
#' Description: Map yearly land cover classes to consistent set of aggregate land use classes 
#' Author: Miriam Gold
#' Date: 22 Mar 2025
#' Last revised: date, initials
#' Notes: 
#' 
# ---------------------------------------------------------------------------- #

# Set up ==========================================
ss <- "18KU40c92CASKVjpC9lSZkgmxztqScb_Rg9c57vKdSl0"

# Read in data ====================================

## Digitized yearly land class code reference tables ======
lcm_code_panel_raw <- read_sheet(ss, sheet = "lcm_codes")

# Clean data ======================================
lcm_code_panel_clean <-
  lcm_code_panel_raw |>
  mutate(
    across(
      c(agg_class, class),
      str_to_lower
    ),
    
    agg_class_clean = str_remove_all(agg_class, "[:punct:]"),
    agg_class_clean = str_squish(agg_class_clean),
    agg_class_clean = 
      str_replace_all(
        agg_class_clean,
        c(
          "standing open water" = "freshwater",
          "oceanic seas" = "saltwater",
          "built up" = "builtup",
          "mountain heath and bog" = "mountain heath bog",
          "broadleaved mixed woodland" = "broadleaf woodland",
          "arable and horticulture" = "arable"
        )
      ),
    
    class_clean = str_remove_all(class, "[:punct:]"),
    class_clean = str_squish(class_clean)
  ) |>
  select(agg_class_clean, year, class_clean, class_no) |>
  arrange(agg_class_clean, year, class_clean, class_no)

# Output ==========================================

lcm_code_panel_clean |>
  write_csv(
    file.path(
      path_data_clean_lc,
      "agg_class_crosswalk",
      "agg_class_crosswalk.csv"
    )
  )
  