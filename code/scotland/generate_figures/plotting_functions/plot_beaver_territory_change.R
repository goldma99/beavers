plot_beaver_territory_change <- function() {
  
  annotation <- 
    tibble(
      year = 2006,
      n_territory = 200,
      text = "Beaver emergence",
      validity = NA
    )
  
  
  tibble(
    year = c(2000, 2012, 2017, 2020),
    n_territory = c(0, 39, 114, 251),
    validity = c("Assumed", rep("Campell et al. (2021) estimate", 3))
  ) %>%
    
    ggplot(
      aes(year, n_territory, color = validity)
    ) +
    
    geom_rect(
      aes(xmin = 2001,
          xmax = 2011,
          ymin = -Inf,
          ymax = 250),
      fill = "#d95f0e",
      color = NA,
      alpha = 0.1
      ) +
    
    geom_text(
      data = annotation,
      aes(label = text),
      color = "black",
      family = "cmss",
      size = 10
    ) +
    
    geom_line(linewidth = 1.25, color = "black") +
    geom_point(size = 4) +
    
    
    scale_y_continuous(
      limits = c(0, NA)
    ) +
    scale_x_continuous(
      breaks = c(2000, 2012, 2017, 2020)
    ) +
    scale_color_manual(
      values = c(
        "Assumed" = "grey60",
        "Campell et al. (2021) estimate" = "#d95f0e"
      ),
      guide = guide_legend(nrow = 1)
    ) +
    
    labs(
      x = NULL,
      y = NULL,
      color = NULL,
      subtitle = "Beaver Territories" #, caption = "\nCampell et al. (2021)"
    ) +
    
    theme_classic() +
    theme(
      text = element_text(family = "cmss", size = 30),
      plot.caption = element_text(size = 20),
      plot.subtitle = element_text(hjust = -0.05),
      panel.grid.major.x = element_blank(),
      panel.grid.minor.x = element_blank(),
      axis.title.y = element_text(angle = 0, hjust = 1),
      legend.position = "bottom"
    )
  
}