plot_era5_grid <- function() {
  
  ggplot() +
    geom_sf(data = river_grid_sf,
            color = "white",
            fill = "grey30") +
    geom_sf(data = era5_grid_sf,
            color = "white",
            fill = "#0f6070",
            alpha = 0.3,
            linewidth = 1.5) +
    theme_minimal() +
    theme(
      text = element_text(family = "cmss", size = 25)
    )
  
}