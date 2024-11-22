plot_treated_cell_land_use <- function() {
  
  
  ## Raw river links ===========
  river_links <-
    path_data_clean_river %>%
    file.path(
      "scotland_river_links",
      "scotland_river_links.shp"
      ) %>%
    vect()
  
  ## River grid cell polygons ==========
  river_grid_vector <-
    path_data_clean_river %>% 
    file.path("river_grid", "river_grid.shp") %>%
    vect()
  
  ## 25x25m Land Cover Maps ========
  raster_year_list <-
    path_data_scotland_ukceh %>%
    dir_ls(recurse = TRUE, glob = "*.tif$") %>%
    map(rast) %>%
    map(~crop(.x, ext(river_grid_vector))) %>%
    map(~ .x[names(.x)[1]]) %>%
    reduce(c)
  
  river_grid_panel <-
    path_data_clean %>%
    file.path(
      "treatment", 
      "river_grid_panel_2period_overall.dta"
      ) %>%
    read_dta()
  
  treated_cells_2017 <-
    river_grid_panel %>%
    filter(g == 2, lccd_mj_dom == "AC", on_river == 1) %>%
    distinct(river_id, g, lccd_mj_dom)
  
  treated_cells_2017_vect <-
    river_grid_vector %>%
    merge(
      treated_cells_2017, 
      by = 'river_id'
      )
  
  land_1990 <- raster_year_list[[1]]
  land_2020 <- raster_year_list[[8]]
  
  treated_cell_example <- treated_cells_2017_vect[100]
  
  land_1990_cropped <- crop(land_1990, treated_cell_example)
  land_2020_cropped <- crop(land_2020, treated_cell_example)
  river_link_cropped <- crop(river_links, treated_cell_example)
  
  plot(land_1990_cropped)
  plot(river_link_cropped, add = TRUE)
  
  
  land_2020_river_distance <- 
    river_link_cropped %>%
    rasterize(land_2020_cropped) %>%
    distance()
  
  set.names(land_2020_river_distance, "river_distance")
  
  plot(c(land_2020_cropped, land_2020_river_distance))
  
  
  land_1990_cropped_df <-
    land_1990_cropped %>%
    as.data.frame(xy = TRUE) %>%
    rename(land_class = 3) %>%
    mutate(land_class_fct = as.factor(land_class))
  
  land_2020_cropped_df <-
    land_2020_cropped %>%
    as.data.frame(xy = TRUE) %>%
    rename(land_class = 3) %>%
    mutate(land_class_fct = as.factor(land_class))
  
  
  bind_rows(
    list(
      "1990" = land_1990_cropped_df,
      "2020" = land_2020_cropped_df
      ),
    .id = "lcm_year"
    ) %>%
    ggplot(aes(x, y, fill = land_class_fct)) +
    geom_tile() +
    coord_fixed() +
    facet_wrap(~lcm_year) +
    # scale_fill_manual(
    #   values = c(`TRUE` = "#1B5E20",
    #              `FALSE` = "#CFD8DC")
    #   ) +
    scale_fill_brewer("Land Class", palette = "Dark2") +
    theme_minimal() +
    theme(
      text = element_text(family = "cmr"),
      axis.text = element_blank(),
      panel.grid = element_blank()
    )

}
