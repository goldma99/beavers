plot_soil_lca_map <- function() {
  
  survey_area <-
    ag_parish_in_survey %>%
    st_transform(4326) %>%
    summarise() %>%
    st_cast("POLYGON")

  
    ggplot() +
      geom_sf(
        data = slice(soil_lca_sf, 1:100000),
        aes(fill = lccd_ds),
        color = NA
        ) +
      geom_sf(data = survey_area, fill = NA, color = "white", linewidth = 1.5) +
      geom_sf(data = survey_area, fill = NA, color = "#C62828", linewidth = 0.25) +
      scale_fill_manual(
        "Soil Agriculture Capability",
        values = c(
          "Arable Cropping" = "#1B5E20",
          "Improved Grassland and Rough Grazings" = "#FFD54F",
          "Non Agricultural (Built, Water, Unmapped)" = "#607D8B"
          )
        ) +
      theme_minimal() +
      theme(
        text = element_text(family = "cmr", size = 19),
        plot.margin = margin(5, 0, 0, 0),
        plot.background = element_rect(fill = "white", color = NA)
      )
  
}