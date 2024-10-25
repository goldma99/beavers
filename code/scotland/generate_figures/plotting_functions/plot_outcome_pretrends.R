plot_outcome_pretrends <- function() {
  
  outcome_var <- "ag_share"
  
  panel_unfilled_pretreat <- 
    river_grid_year_panel_unfilled[,
                                   treatment_year := first_year_treated(year, beaver_d),
                                   by = "river_id"
                                   ][,
                                     g := fcase(is.na(treatment_year) , 0,
                                                treatment_year == 2012, 1,
                                                treatment_year == 2017, 2,
                                                treatment_year == 2020, 3)
                                     ][year %in% 1990:2000 & !is.na(ag_share)]
  panel_unfilled_pretreat %>%
    
    mutate(g = factor(g,
                      levels = c(0, 1, 2, 3),
                      labels = c("Never", "2012", "2017", "2020"))) %>%
    
    #slice_sample(n = 1000) %>%
    
    ggplot(aes(x = factor(year), y = .data[[outcome_var]], group = g, color = g)) +
    
    geom_jitter(
      width = 0.05,
      color = "white",
      shape = 21,
      size = 2,
      stroke = 0.5,
      fill = "grey40",
      alpha = 0.3
      ) +
    geom_smooth(
      se = FALSE, 
      method = "lm",
      linewidth = 1.75
      ) +
    
    scale_color_viridis_d(
      guide = guide_legend(nrow = 2)
    ) +
    scale_x_discrete(
      expand = expansion(add = c(0.15, 0.15))
    ) +
  
    labs(
      subtitle = "Share of Land in Agricultural Use",
      color = "Year Treated",
      y = NULL,
      x = NULL
    ) +
    
    theme_classic() +
    theme(
      text = element_text(family = "cmr", size = 25),
      legend.position = "inside",
      legend.position.inside = c(0.5, 0.85),
      legend.title = element_text(hjust = 0.5)
    )
  
}
