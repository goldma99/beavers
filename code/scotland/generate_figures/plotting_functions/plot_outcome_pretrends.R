plot_outcome_pretrends <- function() {
  
  river_grid_year_panel_unfilled[!is.na(ag_share)] %>%
    filter(
      (g == 0) | 
        (g == 1 & year <= 2000) | 
        (g == 2 & year < 2017) | 
        (g == 3 & year < 2020)
    ) %>% 
    
    mutate(g = factor(g,
                      levels = c(0, 1, 2, 3),
                      labels = c("Never", "2012", "2017", "2020"))) %>%
    
    #slice_sample(n = 1000) %>%
    
    ggplot(
      aes(
        x = year,
        y = ag_share,
        group = g,
        color = g
        )
      ) +
    
    geom_jitter(
      width = 0.3,
      height = 0,
      color = "white",
      shape = 21,
      size = 0.7,
      stroke = 0,#.75,
      fill = "grey10",
      alpha = 0.25
      ) +
    geom_smooth(
      aes(color = g),
      se = FALSE, 
      method = "lm",
      linewidth = 1.75
      ) +
    
    scale_color_viridis_d(
      guide = guide_legend(nrow = 4)
    ) +
    scale_x_continuous(
      breaks = c(1990, 2000, 2007, 2015, 2017:2022)
    ) +
    # scale_x_discrete(
    #   expand = expansion(add = c(0.15, 0.15))
    # ) +
  
    labs(
      subtitle = "Share of Land in Agricultural Use",
      color = "Year Treated",
      y = NULL,
      x = NULL
    ) +
    
    theme_classic() +
    theme(
      text = element_text(family = "cmr", size = 25),
      axis.text.x = element_text(angle = 60, hjust = 1),
      legend.position = "inside",
      legend.position.inside = c(0.2, 0.85),
      legend.title = element_text(hjust = 0.5)
    )
  
}
