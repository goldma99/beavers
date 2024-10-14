plot_lcm_agg_river_grid <- function() {
  
  river_ag_share_y2022_sf <-
    river_ag_share_y2022 %>%
    left_join(river_grid, by = "river_id") %>%
    #slice_sample(n = 1000) %>%
    st_as_sf()
  
  ggplot() +
    geom_sf(data = river_ag_share_y2022_sf,
            aes(fill = ag_share),
            color = NA) +
    scale_fill_viridis_c(
      guide = guide_colorbar(
        direction = "horizontal",
        barwidth = 14
      )
    ) +
    labs(
      fill = "Agriculture Share"
    ) +
    theme_minimal() +
    theme(
      text = element_text(family = "cmr", size = 19),
      legend.position = "inside",
      legend.title.position = "top",
      legend.title = element_text(hjust = 0.5),
      legend.position.inside = c(0.8, 0.9)
    )
    
}