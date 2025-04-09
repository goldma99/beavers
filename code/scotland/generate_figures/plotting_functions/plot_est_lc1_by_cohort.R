plot_est_lc1_by_cohort <- function() {
  
  est_res_lc1_clean <-
    est_res_lc1 %>% 
    filter(parm == "beaver_d") %>%
    select(model, estimate, stderr, min95, max95) %>% 
    mutate(
      dep_var = str_extract(model, "_DV(.*)_TV", group = 1),
      sample_cohort = str_extract(model, "_Sg(\\d{1,3})_", group = 1),
      sample_river = str_extract(model, "_Sg\\d{1,3}_(.*)_(AC|all_soil|IGRG|NAG)", group = 1),
      sample_soil = str_extract(model, "_Sg\\d{1,3}_(.*)_(AC|all_soil|IGRG|NAG)", group = 2),
      control_set = str_extract(model, "_C(.*)_FE", group = 1),
      cohort_includes_1 = str_detect(sample_cohort, "1"),
      cohort_includes_2 = str_detect(sample_cohort, "2"),
      cohort_includes_3 = str_detect(sample_cohort, "3"),
      sample_cohort = fct_relevel(sample_cohort, "1", "2", "3", "12", "13", "23", "123"),
      control_set = case_match(
        control_set,
        "no_controls" ~ "No Controls",
        "weather_controls" ~ "Weather Controls",
        .default = control_set
      )
    ) %>% 
    select(!model) %>% 
    filter(
      sample_river == "river_cells",
      sample_soil == "AC"
    )
  
  inset_cohort_reference <-
    est_res_lc1_clean %>% 
    distinct(sample_cohort, cohort_includes_1, cohort_includes_2, cohort_includes_3) %>% 
    pivot_longer(
      cols = starts_with("cohort_"),
      names_to = "cohort_condition",
      values_to = "inclusion"
    ) %>% 
    mutate(
      cohort_condition = case_when(
        cohort_condition == "cohort_includes_1" ~ "2012",
        cohort_condition == "cohort_includes_2" ~ "2017",
        cohort_condition == "cohort_includes_3" ~ "2020",
        .default = NA_character_
      )
    ) %>% 
    
    ggplot(aes(sample_cohort, cohort_condition, fill = inclusion)) +
    
    geom_tile(color = "white", linewidth = 4) +
    
    coord_fixed(ratio = 0.3) +
    
    scale_fill_manual(
      values = c(
        `TRUE` = "black",
        `FALSE` = "white"
      )
    ) +
    
    labs(
      y = NULL,
      x = "Treatment Cohorts"
    ) +
    
    theme_void() +
    
    theme(
      text = element_text(family = "cmss", size = 25),
      legend.position = "none",
      axis.text.y = element_text(),
      axis.title.x = element_text()
    )
  
  
  plot_est <-
    est_res_lc1_clean %>% 
    
    ggplot(aes(sample_cohort, estimate, color = control_set)) +
    
    geom_point(position = position_dodge(0.6),
               size = 3) +
    geom_errorbar(aes(ymin = min95, ymax = max95),
                  position = position_dodge(0.6),
                  linewidth = 1,
                  width = 0) +
    
    scale_y_continuous(
      limits = c(0, NA)
    ) +
    scale_color_manual(
      values = c(
        "No Controls" = "grey30",
        "Weather Controls" = "#d95f0e"
      )
    ) +
    
    labs(
      x = NULL,
      y = "Estimate",
      color = NULL,
    ) +
    
    theme_classic() +
    theme(
      text = element_text(family = "cmss", size = 25),
      axis.text.x = element_blank(),
      legend.position = "top"
    )
  
  
  plot_est / inset_cohort_reference
  
}
