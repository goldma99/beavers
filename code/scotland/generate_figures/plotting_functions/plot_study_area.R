plot_study_area <- function() {
  
  survey_area <-
    ag_parish_in_survey %>%
    st_transform(4326) %>%
    summarise() %>%
    st_cast("POLYGON")
  
  ggplot() +
    geom_sf(data = nuts_scotland,
            fill = "#CFD8DC",
            color = NA,
            linewidth = 0.5) +
    geom_sf(data = survey_area, 
            fill = "#F57F17",
            color = "white",
            linewidth = 0.7) +
    theme_minimal() +
    theme(
      text = element_text(family = "cmr", size = 19),
    )
  
}