plot_beaver_first_year_treated <- function() {
  
  river_grid_first_year <-
    river_grid_year_panel_filled %>%
    distinct(river_id, beaver_d_fillf_first_year) %>%
    left_join(
      select(river_grid, river_id, on_river),
      by = c("river_id")
    ) %>%
    st_as_sf() %>%
    st_transform(4326)
  
  ggplot() +
    geom_sf(data = river_grid_first_year, fill = "#c9cdcf", color = NA) +
    geom_sf(data = river_grid_first_year, 
            aes(fill = as.factor(beaver_d_fillf_first_year)),
            color = NA) +
    scale_fill_viridis_d(
      guide = guide_legend(
        position = "inside",
        nrow = 1,
        title.position = "top",
        title.hjust = 0.5
      ),
      na.translate = FALSE
    ) +
    labs(
      fill = "First Year Treated"
    ) +
    
    theme_minimal() +
    theme(
      text = element_text(family = "cmr", size = 19),
      legend.position.inside = c(0.8, 0.9),
      legend.background = element_rect(color = NA, fill = "white")
      )
  
}

