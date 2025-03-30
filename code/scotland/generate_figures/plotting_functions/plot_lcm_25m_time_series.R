plot_lcm_25m_time_series <- function() {
  
  beaver_survey <-
    path_data_clean_beaver %>%
    file.path("beaver_survey.pqt") %>% 
    read_parquet()
  
  beaver_survey_sf <-
    beaver_survey %>%
    st_as_sf(
      coords = c("longitude", "latitude"),
      crs = 27700
    ) %>% 
    vect()
  
  grid_cell_candidates <-
    river_grid_year_panel_unfilled |> 
    group_by(river_id) %>% 
    summarise(
      ag_share_1990 = ag_share[year == 1990],
      ag_share_2022 = ag_share[year == 2022],
      ag_share_increased = ag_share_2022 > ag_share_1990,
      on_river = unique(on_river),
      g = unique(g)
    ) %>% 
    filter(
      g > 0 & ag_share_increased,
      on_river,
      !(ag_share_1990 == 0 & ag_share_2022 == 0),
      !(ag_share_1990 == ag_share_2022),
    ) %>% 
    mutate(diff = ag_share_2022 - ag_share_1990)
  
  grid_cell_candidates %>% 
    arrange(desc(diff)) %>% 
    print(n = nrow(.))
  
  example_cell <-
    river_grid %>% 
    filter(river_id == 8050) %>% 
    terra::vect()
  
  rast_cropped <- map(rast_list, ~crop(.x, example_cell))
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
        )
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
    geom_sf(data = river_in_cell) +
    geom_sf(data = beaver_in_cell, 
            aes(color = factor(effective_survey_year)),
            )
  
  
  # 
  # leaflet(data = project(example_cell, "epsg:4326")) %>% 
  #   addTiles() %>% 
  #   addPolygons()
  
  ggplot() +
    
    geom_tile(data = rast_lcm_panel, aes(x, y, fill = lcm), color = "white") +
    
    geom_sf(data = river_in_cell, linewidth = 2, color = "white") +
    geom_sf(data = river_in_cell, linewidth = 1, color = "darkblue") +
    
    geom_sf(data = beaver_in_cell) +
    
    scale_fill_manual(
      values = c(
        "Agriculture" = "#FFD54F",
        "Woodland" = "#2b7f1a",#  "#1B5E20",
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
      axis.text = element_blank()
    )

}

read_ukceh <- function(path) {
  
  year <- str_extract(path, "Map (\\d{4})", group = 1)
  
  rast_obj        <- terra::rast(path)
  land_class_band <- names(rast_obj)[1]
  rast_lc_band    <- rast_obj[[land_class_band]]
  rast_trim <- terra::trim(rast_lc_band)
  
  names(rast_trim) <- year
  
  return(rast_trim)
  
}
