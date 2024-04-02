plot_beaver_parish_expansion <- function() {
  
  # Aggregate beaver observations to the parish-year level
  beaver_obs_by_parish_year <-
    
    beaver_survey_sf %>%
    
    select(nbn_atlas_record_id, effective_survey_year) %>%
    
    st_join(ag_parish_in_survey) %>%
    st_drop_geometry() %>%
    
    group_by(agp_code, effective_survey_year) %>%
    summarise(
      beaver_obs = n()
    ) %>%
    mutate(beaver_obs_d = as.numeric(beaver_obs > 0)) %>%
    ungroup() %>%
    full_join(
      select(
        st_drop_geometry(ag_parish_in_survey),
        !c(agp_name, parish)
        ),
      by = "agp_code"
    ) %>%
    complete(
      agp_code, 
      effective_survey_year = c(2012, 2017, 2020),
      fill = list(
        beaver_obs = 0,
        beaver_obs_d = 0
      )
    ) %>%
    arrange(agp_code, effective_survey_year) %>%
    filter(!is.na(effective_survey_year)) %>%
    group_by(agp_code) %>%
    mutate(
      beaver_obs_d = case_when(
        max(beaver_obs_d) == 0 ~ "Never",
        TRUE ~ as.character(beaver_obs_d))
      ) %>%
     left_join(
      ag_parish_in_survey,
      by = c("agp_code")
      ) %>%
    st_as_sf(crs = 27700)
  
  # Plot 
  
  ## Intensive margin: beaver presence 
  ggplot() +
    
    geom_sf(data = beaver_obs_by_parish_year, 
            aes(fill = as.factor(beaver_obs_d)),
            color = 'white') +
    
    scale_fill_manual(
      "Beaver\npresence",
      values = c(
        "Never" = "grey90",
        "0" = "grey30",
        "1" = "#CD5B45"
        )
    ) +
    
    facet_wrap(~effective_survey_year,
               nrow = 2) +
    
    labs(
      x = "Longitude",
      y = "Latitude"
    ) +
    
    theme_minimal() +
    theme(
      text = element_text(family = "cmr", size = 19),
      axis.title.y = element_text(angle = 0),
      axis.text = element_text(size = 10),
      legend.position = "inside",
      legend.position.inside = c(0.75, 0.25)
    )
  
  
  #' @Note: On-hold until I obtain full set of variables that will allow me to 
  #' correct for the 2017 GPS tech change, and then estimate the actual beaver population
  # ## Extensive margin: beaver population 
  # ggplot() +
  #   geom_sf(data = beaver_obs_by_parish_year, 
  #           aes(fill = beaver_obs),
  #           color = 'white') +
  #   scale_fill_viridis_c(trans = "log10") +
  #   facet_wrap(~effective_survey_year) +
  #   theme_minimal() +
  #   theme(
  #     legend.position = "top"
  #   )
}