plot_lcm_25m_time_series <- function() {
  
  beaver_survey_sf <-
    beaver_survey %>%
    st_as_sf(
      coords = c("longitude", "latitude"),
      crs = 27700
    ) %>% 
    vect()
  
  # grid_cell_candidates <-
  #   river_grid_year_panel_unfilled |> 
  #   group_by(river_id) %>% 
  #   summarise(
  #     ag_share_1990 = ag_share[year == 1990],
  #     ag_share_2022 = ag_share[year == 2022],
  #     ag_share_increased = ag_share_2022 > ag_share_1990,
  #     on_river = unique(on_river),
  #     g = unique(g)
  #   ) %>% 
  #   filter(
  #     g > 0 & ag_share_increased,
  #     on_river,
  #     !(ag_share_1990 == 0 & ag_share_2022 == 0),
  #     !(ag_share_1990 == ag_share_2022),
  #   ) %>% 
  #   mutate(diff = ag_share_2022 - ag_share_1990)
  # 
  # grid_cell_candidates %>% 
  #   arrange(desc(diff)) %>% 
  #   print(n = nrow(.))
  
  example_cell <-
    river_grid %>% 
    filter(river_id == 8050) %>% 
    terra::vect()
  
  rast_cropped <- map(lcm_25m_rast_list, ~crop(.x, example_cell))
  rast_reclass <- map(rast_cropped, classify_agg_ukceh)
  rast_c       <- reduce(rast_reclass, c)
  
  rast_lcm_panel <-
    as.data.frame(rast_c, xy = TRUE) %>% 
    pivot_longer(
      cols = !c(x,y),
      names_to = "year",
      values_to = "lcm"
    ) %>% 
    mutate(
      lcm = case_match(
        lcm,
        1 ~ "Agriculture",
        2 ~ "Woodland",
        3 ~ "Built",
        NA ~ "Other"
        ),
      lcm = fct_relevel(lcm, "Other", after = Inf)
      )
  
  river_in_cell <-
    river_link_sf %>% 
    crop(example_cell) %>%
    st_as_sf()
  
  beaver_in_cell <- 
    beaver_survey_sf %>% 
    crop(example_cell) %>% 
    st_as_sf() %>% 
    mutate(
      year = 
        if_else(
          effective_survey_year == 2012,
          2015,
          effective_survey_year
        )
    )
  
  ggplot() +
    
    geom_tile(data = rast_lcm_panel, aes(x, y, fill = lcm), color = "white") +
    
    geom_sf(data = river_in_cell, linewidth = 2, color = "white") +
    geom_sf(data = river_in_cell, linewidth = 0.75, color = "#3182bd") +
    
    
    geom_sf(data = beaver_in_cell, 
            color = "#d95f0e",
            size = 1.25,
            alpha = 1) +
    
    scale_fill_manual(
      values = c(
        "Agriculture" = "#ffcf33",
        "Woodland" = "#addd8e",#  "#1B5E20",
        "Built" = "grey15", #"#607D8B",
        "Other" = "grey90"
      )
    ) +

    facet_wrap(~year, nrow = 2) +
    
    labs(
      x = "Longitude",
      y = "Latitude",
      fill = NULL,
    ) +
    
    theme_minimal() +
    theme(
      text = element_text(family = "cmss", size = 21),
      legend.position = "right",
      panel.grid = element_blank(),
      axis.title = element_blank(),
      axis.text = element_blank(),
      plot.background = element_rect(color = NA, fill = "white")
    )
}

classify_agg_ukceh <- function(rast) {
  
  stopifnot(length(names(rast))==1)
  
  .year <- names(rast)
  
  lcm_replace_mat <- 
    lcm_class_crosswalk[
      year == .year, 
      .(class_no, agg_class_no)
    ]
  
  classify(rast, lcm_replace_mat)
  
}
