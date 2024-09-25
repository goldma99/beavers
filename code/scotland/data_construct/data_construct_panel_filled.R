# ---------------------------------------------------------------------------- #
#' 
#' Description: Fill in missing panel observations
#' Author: Miriam Gold
#' Date: 25 Sept 2024
#' Last revised: date, mag
#' Notes: 
#'      Methods
#'      - Beaver: 
#'      - Land Use: linearly interpolate between data years (e.g., 1990 -> 2000)
#' 
# ---------------------------------------------------------------------------- #


# Set up ==========================================

## Load packages ====

## File system paths ====

# Read in data ====================================
river_year_panel_unfilled <-
  path_data_clean %>%
  file.path("treatment", "river_grid_year_panel_unfilled.pqt") %>%
  read_parquet()

# Clean data ======================================

# Analysis ========================================

## Land use ======================

# Linearly interpolate agricultural share between available-data years
river_year_panel_unfilled[,
                          ag_share_fill := approx(year, ag_share, n = .N)$y,
                          by = river_id
                          ][,
                            ag_share_fill := pmax(ag_share_fill, 0)
                            ][,
                              ag_share_fill := pmin(ag_share_fill, 1)
                              ]
# [,
#   is_ag_share_fill := if_else(is.na(ag_share), "Interpolated", "Data")
# ]

## Beaver =================

beaver_survey_years <- c(2012, 2017, 2020)

#' @Note First, we must impute zeroes in any year where we know there was a 
#' survey. This is because the survey was spatially comprehensive, but the data
#' only reports positive sighting.  
river_year_panel_unfilled[
  year %in% beaver_survey_years & is.na(beaver_d),
  beaver_d := 0
  ]

# We know 1990 was before beaver entry, and this conveniently serves as a 
# "doorstop" for the fill-forward and fill-backward below
#' @TODO: Consider filling in 1990-2000. Find a citation that could justify some 
#' confidence in defining a pre-period
river_year_panel_unfilled[year %in% seq(1990, 2000), beaver_d := 0]

river_year_panel_beaver_fill <-
  river_year_panel_unfilled %>%
  group_by(river_id) %>%
  mutate(
    beaver_d_fillf = beaver_d,
    beaver_d_fillb = beaver_d
    ) %>%
  fill(beaver_d_fillf, .direction = "down")  %>%
  fill(beaver_d_fillb, .direction = "updown") %>%
  mutate(
    never_treated_fillf = as.integer(max(beaver_d_fillf) == 0),
    never_treated_fillb = as.integer(max(beaver_d_fillb) == 0),
    beaver_d_fillf_first_year = first_year_treated(year, beaver_d_fillf, 1),
    beaver_d_fillb_first_year = first_year_treated(year, beaver_d_fillb, 1)
  ) %>%
  ungroup()

# Output ==========================================
river_year_panel_beaver_fill %>%
  write_parquet(
    file.path(path_data_clean, "treatment", "river_grid_year_panel_filled.pqt")
  )

