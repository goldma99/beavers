# ---------------------------------------------------------------------------- #
#' 
#' Description: Main beaver impacts specification
#' Author: Miriam Gold
#' Date: 25 Oct 2024
#' Last revised: date, mag
#' Notes: notes
#' 
# ---------------------------------------------------------------------------- #

# Set up ==========================================

## Load packages ====

## File system paths ====

# Read in data ====================================

treatment_panel_list <-
  c("overall", "g1", "g2") %>%
  purrr::set_names() %>%
  map(read_treatment_panel)

# Regressions ========================================
lhs <- c("ag_share", "level_mean", "level_max", "flow_mean")

y_mean_overall <- treatment_panel_list$overall[, lapply(.SD, 
                                                        \(x) round(mean(x, na.rm = TRUE), 3)
                                                        ), .SDcols = lhs] %>%
  as.vector() %>%
  list_c()

y_mean_g2 <- treatment_panel_list$g2[, lapply(.SD, 
                                              \(x) round(mean(x, na.rm = TRUE), 3)
                                              ), .SDcols = lhs]
y_mean_g1 <- treatment_panel_list$g1[, lapply(.SD, 
                                              \(x) round(mean(x, na.rm = TRUE), 3)
                                              ), .SDcols = lhs]

est_main_Soverall <-
  feols(
    fml = .[lhs] ~ beaver_d | river_id + t_overall,
    data = treatment_panel_list$overall
)

est_main_Soverall_river <-
  feols(
    fml = .[lhs] ~ beaver_d | river_id + t_overall,
    data = treatment_panel_list$overall[on_river == 1]
  )

panelsummary_raw(
    est_main_Soverall,
    est_main_Soverall_river
    ) %>%
  clean_raw()


est_main_Sg1 <-
  feols(
    fml = .[lhs] ~ beaver_d | river_id + t_g1,
    data = treatment_panel_list$g1
  )

est_main_Sg2 <-
  feols(
    fml = .[lhs] ~ beaver_d | river_id + t_g2,
    data = treatment_panel_list$g2
  )

# Output ==========================================
beaver_dict <- 
  c(
    "beaver_d" = "Beaver Presence",
    "ag_share" = "Share Agri.",
    "level_mean" = "River level (mean)",
    "level_max" = "River level (max)",
    "flow_mean" = "River flow (mean)",
    "river_id" = "Grid cell",
    "t_overall" = "Period",
    "t_g1" = "Time Period",
    "t_g2" = "Time Period"
    )

note_overall <-
  "Each column reports results from a two-way fixed effects regression.
   Landscape grid cell and time period (pre- and post-beaver entry) are included.
   Standard errors are clustered at the landscape grid cell level.
   Regression sample includes all never-treated and ever-treated units." %>%
  str_remove_all("\\n")

esttab_main_Soverall <-
  esttex(
    est_main_Soverall,
    title = "Beaver impacts on agriculture and river characteristics.", 
    notes = note_overall,
    style.tex = style.tex("qje"),
    dict = beaver_dict,
    digits = "r3",
    digits.stats = "s3",
    fitstat = c("n", "wr2"),
    extralines = list("_Mean Dep Var" = y_mean_overall)
    )
esttab_main_Soverall %>%
  write(
    file.path(path_output_tables, "est_main_Soverall.tex")
  )

etable(est_main_Sg1)
etable(est_main_Sg2)
