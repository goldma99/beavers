plot_transloc_plant <- function() {
  
  plant_transloc_raw |>
    rename(plant_transloc = y) |>
    mutate(
      decade = c("2011-2022", "2001-2010", "1991-2000", "1980-1990", "<1980"),
      decade = fct_inorder(decade),
      decade = fct_rev(decade)
    ) |>
    ggplot(
      aes(
        decade, plant_transloc, group = 1
      )
    ) +
    
    geom_bar(
      stat = "identity",
      fill = "#E69F00",
      width = 0.4
    ) +
    
    geom_hline(
      yintercept = 0
    ) +
    scale_y_continuous(
      limits = c(0, 2000),
      expand = expansion(add = c(0, 20))
    ) +

    labs(
      x = "Decade",
      y = NULL,
      subtitle = "Plant Translocations",
      caption = "Reproduced from\nGodefroid et al. (2025), Fig. 1d"
    ) +
    
    theme_classic() +
    theme(
      text = element_text(family = "cmss", size = 30),
      plot.caption = element_text(size = 20),
      panel.grid.major.x = element_blank(),
      axis.title.y = element_text(angle = 0, hjust = 1)
    )
}