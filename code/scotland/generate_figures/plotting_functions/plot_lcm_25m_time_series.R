plot_lcm_25m_time_series <- function() {
  
  beaver_survey_sf <-
    beaver_survey %>%
    st_as_sf(
      coords = c("longitude", "latitude"),
      crs = 27700
    ) %>% 
    vect()
  # 
  # grid_cell_candidates <-
  #   river_grid_year_panel_unfilled |>
  #   group_by(river_id) %>%
  #   summarise(
  #     ag_share_1990 = is_land_class_1[year == 1990],
  #     ag_share_2022 = is_land_class_1[year == 2022],
  #     ag_share_increased = ag_share_2022 > ag_share_1990,
  #     on_river = unique(on_river),
  #     g = unique(g)
  #   ) %>%
  #   filter(
  #     g == 2 & ag_share_increased,
  #     on_river,
  #     ag_share_1990 != 0,
  #     ag_share_2022 != 0,
  #     #!(ag_share_1990 == ag_share_2022),
  #   ) %>%
  #   mutate(diff = ag_share_2022 - ag_share_1990)
  # 
  # grid_cell_candidates %>%
  #   arrange(desc(diff)) %>%
  #   print(n = nrow(.))

  example_cell <-
    river_grid %>% 
    filter(river_id == 7963) %>% 
    terra::vect()
  
  rast_cropped <- map(lcm_25m_rast_list, ~crop(.x, example_cell))
  rast_reclass <- map(rast_cropped, classify_agg_ukceh)
  rast_c       <- reduce(rast_reclass, c)
  
  lcm_class_crosswalk_clean <- 
    lcm_class_crosswalk %>% 
    distinct(agg_class_no, year, agg_class_clean) %>% 
    drop_na()
  
  rast_lcm_panel <-
    as.data.frame(rast_c, xy = TRUE) %>% 
    pivot_longer(
      cols = !c(x,y),
      names_to = "year",
      values_to = "lcm"
    ) %>%
      mutate(year = as.numeric(year)) %>% 
    left_join(
      lcm_class_crosswalk_clean,
      by = join_by(year, lcm == agg_class_no)
    ) %>% 
    mutate(
      lcm = case_match(
        lcm,
        1 ~ "Agriculture",
        3 ~ "Built",
        .default = "Other"
        ),
      lcm = fct_relevel(lcm, "Other", after = Inf)
      )
  
  river_in_cell <-
    river_link_sf %>% 
    crop(example_cell) %>%
    st_as_sf()
  
  beaver_in_cell_coords <- 
    beaver_survey_sf %>% 
    crop(example_cell) %>% 
    st_as_sf() 
  
  beaver_in_cell <-
    beaver_in_cell_coords %>% 
    st_drop_geometry() %>% 
    select(beaver_id = nbn_atlas_record_id, year = effective_survey_year) %>%
    group_by(beaver_id) %>%
    complete(year = seq(min(year), 2022)) %>% 
    left_join(
      select(beaver_in_cell_coords, nbn_atlas_record_id),
      by = join_by(beaver_id == nbn_atlas_record_id)
    ) %>% 
    st_as_sf()
  # library(leaflet)
  # 
  # example_cell_sf <- 
  #   st_as_sf(example_cell) %>% 
  #   st_transform(4326)
  # 
  # leaflet() %>% 
  #   leaflet::addTiles() %>% 
  #   addPolygons(data = example_cell_sf)
  # 
  ggplot() +
    
    geom_tile(data = rast_lcm_panel, aes(x, y, fill = lcm), color = "white") +
    
    geom_sf(data = river_in_cell, linewidth = 2, color = "white") +
    geom_sf(data = river_in_cell, linewidth = 0.75, color = "#3182bd") +
    
    
    geom_sf(data = beaver_in_cell, 
            aes(color = "Beaver sight/sign"),
             size = 1.5,
             alpha = 1) +
    
    scale_color_manual(
      values = c(
        "Beaver sight/sign" = "#d95f0e"
      )
    ) +
     
     scale_fill_manual(
       values = c(
        "Agriculture" = "#ffcf33",
        #"Woodland" = "#addd8e",#  "#1B5E20",
        "Built" = "grey15", #"#607D8B",
        "Other" = "grey90"
      )
    ) +
  
    facet_wrap(~year, nrow = 2) +
    
    labs(
      x = "Longitude",
      y = "Latitude",
      fill = NULL,
      color = NULL
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

