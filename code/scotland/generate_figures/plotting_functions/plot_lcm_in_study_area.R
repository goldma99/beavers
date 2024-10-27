plot_lcm_in_study_area <- function() {
  
  lcm_crop_to_study_y2022_dt <-
    lcm_crop_to_study_y2022 %>% 
    project("epsg:4326") %>%
    as.data.table(xy = TRUE) %>%
    setnames(
      old = "ukregion-scotland_1",
      new = "class"
      )
  
  class_desc_vals <- c("Agriculture", "Other")
  
  lcm_crop_to_study_y2022_dt[class == 3, class_desc := class_desc_vals[1]]
  lcm_crop_to_study_y2022_dt[class != 3, class_desc := class_desc_vals[2]]
  
  n <- nrow(lcm_crop_to_study_y2022_dt)
 
  coord_ratio <- 
    diff(lcm_crop_to_study_y2022_dt[,range(x)])/diff(lcm_crop_to_study_y2022_dt[,range(y)])
  
  ggplot() +
      geom_tile(
        data = lcm_crop_to_study_y2022_dt,
        aes(x, y, fill = class_desc)
        ) +
      
      scale_fill_manual(
        values = set_names(c("#1B5E20", "#CFD8DC"), class_desc_vals)
      ) +
      
      coord_fixed(ratio = coord_ratio) +
      
      labs(
        fill = NULL,
        x = "Longitude",
        y = "Latitude"
      ) +
      
      theme_minimal() +
      theme(
        text = element_text(family = "cmr", size = 19),
        legend.position = "top"
      )
  
}
