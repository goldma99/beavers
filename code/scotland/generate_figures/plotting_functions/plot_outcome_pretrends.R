plot_outcome_pretrends <- function() {
  
  river_grid_year_panel_unfilled[!is.na(is_land_class_1)] %>%
    # filter(
    #   (g == 0) | 
    #     (g == 1 & year <= 2000) | 
    #     (g == 2 & year <= 2012) | 
    #     (g == 3 & year <= 2017)
    # ) %>% 
    #count(g, year)

    mutate(
      
      g_pre_post = case_when(
        g == 0 ~ "Never",
        g == 1 & year <= 2000 ~ "pre",
        g == 1 & year >= 2012 ~ "post",
        g == 2 & year <= 2012 ~ "pre",
        g == 2 & year >= 2017 ~ "post",
        g == 3 & year <= 2017 ~ "pre",
        g == 3 & year >= 2020 ~ "post",
        .default = NA_character_
        ),
      
      g = factor(
        g,
        levels = c(0, 1, 2, 3),
        labels = c("Never", "2012", "2017", "2020")
        ),
      plot_group = paste0(g, ":", g_pre_post)
      ) %>%
      filter(!is.na(g_pre_post)) %>% 
    
    #slice_sample(n = 1000) %>%
    
    ggplot(
      aes(
        x = year,
        y = is_land_class_1,
        group = plot_group,
        color = g,
        lty = g_pre_post
        )
      ) +
    
    geom_jitter(
      width = 0.3,
      height = 0,
      color = "white",
      shape = 21,
      size = 0.7,
      stroke = 0,#.75,
      fill = "grey15",
      alpha = 0.25
      ) +
    geom_smooth(
      color = "white",
      se = FALSE, 
      method = "lm",
      linewidth = 3.75
    ) +
    geom_smooth(
      aes(color = g),
      se = FALSE, 
      method = "lm",
      linewidth = 1.5
      ) +
    
    scale_color_viridis_d(
      guide = guide_legend(nrow = 4)
    ) +
    scale_x_continuous(
      breaks = c(1990, 2000, 2007, 2015, 2017:2022)
    ) +
    scale_linetype_manual(
      values = c(
        "Never" = 1,
        "pre" = 1,
        "post" = 5
      ),
      guide = "none"
    ) +
  
    labs(
      subtitle = "Share of Land in Agricultural Use",
      color = "Treatment Cohort",
      y = NULL,
      x = NULL
    ) +
    
    theme_classic() +
    theme(
      text = element_text(family = "cmss", size = 25),
      axis.text.x = element_text(angle = 60, hjust = 1),
      legend.position = "inside",
      legend.position.inside = c(0.2, 0.85),
      legend.title = element_text(hjust = 0.5)
    )
  
}
