plot_treated_cell_land_use <- function() {
  ## River grid cell polygons ==========
  river_grid_vector <-
    path_data_clean_river %>% 
    file.path("river_grid", "river_grid.shp") %>%
    vect()
  
  ## 25x25m Land Cover Maps ========
  raster_year_list <-
    path_data_scotland_ukceh %>%
    dir_ls(recurse = TRUE, glob = "*.tif$") %>%
    map(rast)
  
  river_grid_panel <-
    path_data_clean %>%
    file.path(
      "treatment", 
      "river_grid_panel_2period_overall.dta"
      ) %>%
    read_dta()
  
  treated_cells_2017 <-
    river_grid_panel %>%
    filter(g == 2) %>%
    distinct(river_id, g)
  
  treated_cells_2017_vect <-
    river_grid_vector %>%
    merge(
      treated_cells_2017, 
      by = 'river_id'
      )
  
  land_1990 <- raster_year_list[[1]]
  land_2020 <- raster_year_list[[8]]
  
  treated_cell_example <- treated_cells_2017_vect[18]
  
  land_1990_cropped <- crop(land_1990, treated_cell_example)
  land_2022_cropped <- crop(land_2022, treated_cell_example)
  
  land_1990_cropped_df <-
    land_1990_cropped %>%
    as.data.frame(xy = TRUE) %>%
    rename(land_class = 3) %>%
    mutate(land_class_fct = as.factor(land_class))
  
  land_2022_cropped_df <-
    land_2022_cropped %>%
    as.data.frame(xy = TRUE) %>%
    rename(land_class = 3) %>%
    mutate(land_class_fct = as.factor(land_class))
  
  
  bind_rows(
    list(
      "1990" = land_1990_cropped_df,
      "2020" = land_2022_cropped_df
      ),
    .id = "lcm_year"
    ) %>%
    ggplot(aes(x, y, fill = land_class_fct == 3)) +
    geom_tile() +
    coord_fixed() +
    facet_wrap(~lcm_year) +
    scale_fill_manual(
      values = c(`TRUE` = "#1B5E20",
                 `FALSE` = "#CFD8DC")
      ) +
    theme_minimal() +
    theme(
      text = element_text(family = "cmr")
    )

}
