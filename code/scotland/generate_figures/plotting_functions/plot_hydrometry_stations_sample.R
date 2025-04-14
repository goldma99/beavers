plot_hydrometry_stations_sample <- function() {
  
  ggplot() +

    geom_sf(
      data = river_grid_sf,
      color = NA,
      fill = "grey90",
      linewidth = 0.1
      ) +
    
    geom_sf(
      data = hydrometry_metadata_sf,
      shape = 21,
      size = 3,
      stroke = 1,
      fill = "#2b8397",
      color = "white"
    ) +
    
    theme_minimal() +
    theme(
      text = element_text(family = "cmss", size = 25)
    )
    
}