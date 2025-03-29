# ---------------------------------------------------------------------------- #
#' 
#' Description: Balance table of covariates and outcome var by treated status 
#' Author: Miriam Gold
#' Date: 29 Mar 2025
#' Last revised: date, initials
#' Notes: 
#' 
# ---------------------------------------------------------------------------- #

# Set up ==========================================

# Read in data ====================================

## Panel: unfilled 
river_grid_year_panel_unfilled <-
  path_data_clean %>%
  file.path(
    "treatment", 
    "river_grid_year_panel_unfilled.pqt"
  ) %>%
  read_parquet()

# Clean data ======================================

data_ttest <-
  river_grid_year_panel_unfilled %>% 
  filter(
    (g == 0) | 
      (g == 1 & year <= 2000) | 
      (g == 2 & year < 2017) | 
      (g == 3 & year < 2020)
  ) %>% 
  mutate(treated = g > 0,
         tp_mean = tp_mean/1000) %>% 
  select(
    treated, on_river, ag_share, tp_mean, t2m_mean, soil_share_ac
  ) %>% 
  pivot_longer(
    !treated,
    names_to = "var"
  ) %>% 
  group_by(var) %>% 
  summarise(
    tidy(t.test(value[treated], value[!treated]))
  )

# Analysis ========================================

gt_ttest_latex <-
  data_ttest %>% 
  select(var,
         estimate1,
         estimate2,
         estimate,
         p.value) %>%
  mutate(
    across(
      !c(var, p.value),
      scales::label_comma(accuracy = 0.001)
    ),
    estimate = case_when(
      p.value > 0.1 ~ estimate,
      p.value > 0.05 ~ paste0(estimate, "*"),
      p.value > 0.01 ~ paste0(estimate, "**"),
      .default = paste0(estimate, "***")
    ),
    var = case_match(
      var,
      "ag_share" ~ "Share Ag. Use",
      "on_river" ~ "Cell on river",
      "soil_share_ac" ~ "Share Ag. Soil",
      "t2m_mean" ~ "Temp",
      "tp_mean" ~ "Precip"
    ),
  ) %>% 
  select(!p.value) %>% 
  gt() %>% 
  cols_label(
    var = "",
    estimate1 = "Treated",
    estimate2 = "Control",
    estimate = "Diff in Means"
  ) %>% 
  as_latex() %>% 
  as.character()

# Output ==========================================
gt_ttest_latex %>% 
  write_lines(
    file.path(
      path_output_tables, "descriptive", "balance_ttest.tex"
    )
  )


  
