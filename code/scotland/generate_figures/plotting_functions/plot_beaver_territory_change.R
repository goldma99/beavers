plot_beaver_territory_change <- function() {
  
  tibble(
    year = c(2012, 2017, 2020),
    n_territory = c(39, 114, 251) 
  ) %>%
    
    ggplot(
      aes(year, n_territory)
    ) +
    geom_line(linewidth = 1.5) +
    geom_point(size = 3.25) +
    
    scale_y_continuous(
      limits = c(0, NA)
    ) +
    scale_x_continuous(
      breaks = c(2012, 2017, 2020)
    ) +
    
    labs(
      x = "Survey Year",
      y = NULL,
      subtitle = "Estimated Beaver Territories",
      caption = "Campell et al. (2021)"
    ) +
    
    theme_classic() +
    theme(
      text = element_text(family = "cmss", size = 30),
      plot.caption = element_text(size = 20),
      panel.grid.major.x = element_blank(),
      panel.grid.minor.x = element_blank(),
      axis.title.y = element_text(angle = 0, hjust = 1)
    )
  
}