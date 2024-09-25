
plot_ag_share_fill <- function(data, id) {
  
  message("Plotting river grid cell ", id)
  
  data[river_id == id] %>%
    
    ggplot(
      aes(year, ag_share_fill, shape = is_ag_share_fill, color = is_ag_share_fill)
    ) +
    
    geom_point(size = 3) +
    
    scale_color_manual(values = c(Interpolated = "#90A4AE", Data = "#D84315")) +
    scale_shape_manual(values = c(Interpolated = 16       , Data = 17)) +
    scale_x_continuous(breaks = seq(1990, 2022, by = 1)) +
    scale_y_continuous(limits = c(0, 1), labels = scales::label_percent()) +
    
    labs(
      x = NULL,
      y = NULL,
      subtitle = "% Land in Agricultural Use",
      color = NULL,
      shape = NULL
    ) +
    
    theme_classic() +
    theme(
      text = element_text(size = 19),
      axis.text.x = element_text(size = 12, angle = 30, hjust = 1)
    )
  
  ggsave(filename = glue("ag_share_fill_id{id}.png"),
         path = file.path(path_output_figures, "ag_share_fill"),
         width = 12, height = 7, units = "in")
}