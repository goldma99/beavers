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
                               `:=`(t_overall = fcase(year %in% 1990:2000, 0,
                                                      year %in% 2020:2022, 1),
                                    t_g1      = fcase(year %in% 1990:2000, 0,
                                                      year %in% 2012:2022, 1),
                                    t_g2      = fcase(year %in% 1990:2000, 0,
                                                      year %in% 2017:2022, 1))
                               ]

river_grid_year_panel_unfilled[,
                               treatment_year := first_year_treated(year, beaver_d),
                               by = "river_id"
                               ]

# Treatment groups 
river_grid_year_panel_unfilled[,
                               g := fcase(is.na(treatment_year) , 0,
                                          treatment_year == 2012, 1,
                                          treatment_year == 2017, 2,
                                          treatment_year == 2020, 3)
                               ]

# Aggregate to grid-cell-by-t, with all covariates averaged
sd_cols <- str_subset(names(river_grid_year_panel_unfilled), "_?mean_?|_max|ag_share")

hydro_vars_usable <- c("flow_mean", "level_mean", "level_max")
hydro_vars_to_drop <- c("groundwaterlevel_mean", "groundwaterlevel_max", "flow_max")

## Overall sample =================
river_grid_panel_2period_overall <-
  river_grid_year_panel_unfilled[,
                                 c(.(g = unique(g)),
                                   lapply(.SD, mean, na.rm = TRUE)),
                                 by = .(river_id, t_overall),
                                 .SDcols = sd_cols
                                 ][,
                                   (sd_cols) := map(.SD, ~ na_if(.x, NaN)),
                                   .SDcols = sd_cols
                                   ][
                                     !is.na(t_overall)
                                     ][,
                                       beaver_d := fcase(g == 0 | t_overall == 0, 0,
                                                       default = 1)
                                       ][,
                                         !..hydro_vars_to_drop
                                         ]

## Only 2012-treated =================
river_grid_panel_2period_g1 <-
  river_grid_year_panel_unfilled[!g %in% c(2, 3),
                                 c(.(g = unique(g)),
                                   lapply(.SD, mean, na.rm = TRUE)),
                                 by = .(river_id, t_g1),
                                 .SDcols = sd_cols
                                 ][,
                                   (sd_cols) := map(.SD, ~ na_if(.x, NaN)),
                                   .SDcols = sd_cols
                                   ][
                                     !is.na(t_g1)
                                     ][,
                                       beaver_d := fcase(g == 0 | t_g1 == 0, 0,
                                                       default = 1)
                                       ][,
                                         !..hydro_vars_to_drop
                                         ]
## Only 2012- and 2017-treated =================
river_grid_panel_2period_g2 <-
  river_grid_year_panel_unfilled[g != 3,
                                 c(.(g = unique(g)),
                                   lapply(.SD, mean, na.rm = TRUE)),
                                 by = .(river_id, t_g2),
                                 .SDcols = sd_cols
                                ][,
                                  (sd_cols) := map(.SD, ~ na_if(.x, NaN)),
                                  .SDcols = sd_cols
                                  ][
                                    !is.na(t_g2)
                                    ][,
                                      beaver_d := fcase(g == 0 | t_g2 == 0, 0,
                                                        default = 1)
                                      ][,
                                        !..hydro_vars_to_drop
                                        ]
# Output ==========================================
river_grid_panel_2period_overall %>%
  write_parquet(
    file.path(path_data_clean, "treatment", "river_grid_panel_2period_overall.pqt")
  )

river_grid_panel_2period_g1 %>%
  write_parquet(
    file.path(path_data_clean, "treatment", "river_grid_panel_2period_g1.pqt")
  )

river_grid_panel_2period_g2 %>%
  write_parquet(
    file.path(path_data_clean, "treatment", "river_grid_panel_2period_g2.pqt")
  )
