
plot_ag_share_fill <- function() {
  
  .id <- 752
  
  survey_area <- 
    ag_parish_in_survey %>%
    summarise() %>%
    st_cast("POLYGON")
  
  river_grid_752 <- 
    river_grid %>%
    filter(river_id == .id) %>%
    st_buffer(1000)
  
  map_inset <-
    ggplot() +
    geom_sf(data = survey_area,
            color = NA) +
    geom_sf(data = river_grid_752,
            fill = "#1A237E",
            color = NA) +
      geom_sf_text(data = river_grid_752,
                   aes(label = glue("River cell {river_id}")),
                   nudge_x = 10000,
                   nudge_y = 10000,
                   color = "#1A237E",
                   family = "cmr") +
    theme_void()
  
  
  message("Plotting river grid cell ", .id)
  
  river_grid_year_panel_filled[river_id == .id] %>%
    mutate(is_ag_share_fill = if_else(is.na(ag_share), "Interpolated", "Data")) %>%
    
    ggplot(
      aes(year, 
          ag_share_fill, 
          shape = is_ag_share_fill, 
          color = is_ag_share_fill,
          group = 1)
    ) +
    
    #geom_line(color = 'grey', linewidth = 1.5) +
    geom_point(size = 4) +
    
    annotation_custom(
      ggplotGrob(map_inset),
      xmin = 1990, xmax = 1997, ymin = 0.1, ymax = 0.4
    ) +
    
    scale_color_manual(values = c(Interpolated = "#90A4AE", Data = "#F57F17")) +
    scale_shape_manual(values = c(Interpolated = 16       , Data = 17)) +
    scale_x_continuous(breaks = c(1990, 2000, 2007, 2015, 2017:2022)) +
    scale_y_continuous(limits = c(0, NA), labels = scales::label_percent()) +
    
    labs(
      x = NULL,
      y = NULL,
      subtitle = "% Land in Agricultural Use",
      color = NULL,
      shape = NULL
    ) +
    
    theme_classic() +
    theme(
      text = element_text(family = "cmr", size = 20),
      axis.text.x = element_text(size = 13, angle = 30, hjust = 1),
      legend.position = "inside",
      legend.position.inside = c(0.15, 0.85)
    )
}