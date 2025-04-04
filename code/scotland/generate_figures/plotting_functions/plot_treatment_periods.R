plot_treatment_periods <- function() {
  
  data_treatment_period <-
    expand_grid(
      year = 1990:2022,
      g = 0:3
      ) %>%
    arrange(g, year) %>%
    mutate(
      status =
        case_when(
          g == 0 ~ "Untreated",
          g == 1 & year <= 2000 ~ "Pre-treatment",
          g == 1 & year >= 2012 ~ "Post-treatment",
          g == 2 & year <= 2012 ~ "Pre-treatment",
          g == 2 & year >= 2017 ~ "Post-treatment",
          g == 3 & year <= 2017 ~ "Pre-treatment",
          g == 3 & year >= 2020 ~ "Post-treatment"
        ),
      cohort = case_when(
        g == 0 ~ "Never",
        g == 1 ~ "2012",
        g == 2 ~ "2017",
        g == 3 ~ "2020"
      ),
      cohort = fct_relevel(cohort, "Never", "2012", "2017", "2020"),
      status = fct_rev(status)
    ) %>% 
    drop_na()
  
  annotations <- 
    tibble(
      cohort = rep("2020", 4),
      year = c(2000, 2012, 2017, 2020),
      text = c("Beavers arrive", "Survey", "Survey", "Survey"),
      status = "Untreated"
    ) %>% 
    slice(1)
  
  data_treatment_period %>% 
    
    ggplot(aes(year, cohort, fill = status)) +
    
    geom_tile(color = "white", linewidth = 1) +
    
    scale_x_continuous(
      breaks = c(1990, 2000, 2012, 2017, 2020)
    ) +
    scale_fill_manual(
      values = c(
        "Untreated" = "grey70",
        "Pre-treatment" = "#ffdfb8",
        "Post-treatment" = "#E69F00"
      )
    ) +
    
    coord_fixed() +
    
    labs(
      fill = NULL,
      x = NULL,
      y = NULL,
      subtitle = "Treatment Cohort"
    ) +
  
    theme_minimal() +
    theme(
      text = element_text(family = "cmss", size = 25),
      plot.subtitle = element_text(hjust = -0.075, size = 20),
      legend.position = "bottom",
      panel.grid.minor.x = element_blank(),
      panel.grid.major.x = element_blank()
    )
  
}