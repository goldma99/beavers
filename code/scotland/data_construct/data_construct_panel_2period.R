# ---------------------------------------------------------------------------- #
#' 
#' Description: Construct 2-period panel for static DiD
#' Author: Miriam Gold
#' Date: 19 October 2024
#' Last revised: date, mag
#' Notes: 
#'        Relative treatment periods
#'        t=0 is the pre-treatment period for everyone (1990-2000)
#'        t=1 is the post-treatment period for everyone (2020-2022)
#'        
#'        Groups are: 
#'        g = 0 (never-treated)
#'        g = 1 (treated in 2012)
#'        g = 2 (treated in 2017)
#'        g = 3 (treated in 2020)
#'        
#'        For robustness, I'll check by group. So I'll do a version
#'        where with only g_2, where the t=1 includes 2017:2022, and so on
# ---------------------------------------------------------------------------- #

# Set up ==========================================

## Load packages ====

## File system paths ====

# Read in data ====================================
river_grid_year_panel_unfilled <-
  path_data_clean %>%
  file.path(
    "treatment", 
    "river_grid_year_panel_unfilled.pqt"
    ) %>%
  read_parquet()

# Clean data ======================================

## Label periods and groups ===============

# Pre- and post-treatment periods
river_grid_year_panel_unfilled[,
                               t := fcase(year %in% 1990:2000, 0,
                                          year %in% 2020:2022, 1)
                               ]

river_grid_year_panel_unfilled[,
                               `:=`(first_year_treated = first_year_treated(year, beaver_d),
                                    ever_treated = !is.na(first_year_treated)),
                               by = "river_id"]

# Treatment groups 
river_grid_year_panel_unfilled[,
                               g := fcase(is.na(first_year_treated) , 0,
                                          first_year_treated == 2012, 1,
                                          first_year_treated == 2017, 2,
                                          first_year_treated == 2020, 3)
                               ]

# Aggregate to grid-cell-by-t, with all covariates averaged
sd_cols <- str_subset(names(river_grid_year_panel_unfilled), "_?mean_?|_max|ag_share")

hydro_vars_usable <- c("flow_mean", "level_mean", "level_max")
hydro_vars_to_drop <- c("groundwaterlevel_mean", "groundwaterlevel_max", "flow_max")

river_grid_panel_2period <-
  river_grid_year_panel_unfilled[,
                                 c(
                                   .(g = unique(g),
                                     ever_treated = unique(ever_treated)),
                                   lapply(.SD, mean, na.rm = TRUE)
                                   ),
                                 by = .(river_id, t),
                                 .SDcols = sd_cols
                                 ][,
                                   (sd_cols) := map(.SD, ~ na_if(.x, NaN)),
                                   .SDcols = sd_cols
                                   ][
                                     !is.na(t)
                                   ][,
                                     beaver_d := fcase(g == 0 | t == 0, 0,
                                                       default = 1)
                                     ][, 
                                       !..hydro_vars_to_drop
                                     ]

nonmissing_level <-
  river_grid_panel_2period %>%
  group_by(river_id) %>%
  filter(ever_treated,
         all(!is.na(level_mean)))
  
library(fixest)
feols(
  ag_share ~ beaver_d | mean_elevation + mean_slope + river_id + t,
  data = river_grid_panel_2period
  )
  broom::tidy()

# Output ==========================================
river_grid_panel_2period %>%
  write_parquet(
    file.path(path_data_clean, "treatment", "river_grid_panel_2period.pqt")
  )
