plot_transloc_animal <- function() {
  
  animal_transloc_by_year <-
    animal_transloc_raw |>
    separate_longer_delim(
      years,
      delim = ", "
    ) |>
    mutate(
      years = as.integer(years),
      decade = floor_date.decade(years)
    ) |>
    count(decade) |>
    filter(
      between(decade, 1880, 2010)
    )
  
  
  animal_transloc_by_year |>
    ggplot(
      aes(decade, n)
    ) +
    
    geom_bar(stat = "identity",
             width = 6,
             fill = "#E69F00") +
    
    scale_x_continuous(
      breaks = seq(1880, 2010, by = 10)
    ) +
    
    scale_y_continuous(
      expand = expansion(add = c(0, 20))
    ) +
    
    labs(
      x = "Decade",
      y = NULL,
      subtitle = "Animal Translocations",
      caption = "Colas and Sarrazin (2024)"
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