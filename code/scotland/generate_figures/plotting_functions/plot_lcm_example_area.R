plot_lcm_example_area <- function() {
  
  lcm_palette <- 
    path_data_scotland_ukceh %>%
    file.path("Land Cover Map 2022 (25m rasterised land parcels, GB)/supporting-docs/lcm_raster_cb_friendly.qml") %>%
    read_lines()
  
  lcm_palette_df <-
    lcm_palette[26:46] %>%
    str_trim() %>%
    str_replace_all("\\\"", "'") %>%
    str_remove_all("<paletteEntry |>|/") %>%
    tibble(pal_entry = .)
  
  lcm_palette_clean <-
    lcm_palette_df %>%
    separate_wider_delim(
      pal_entry, 
      names = c("land_class", "alpha", "color", "label"), 
      delim = "' "
    ) %>%
    mutate(
      across(.cols = everything(), .fns = ~ str_remove_all(.x, "'|=|value|alpha|color|label")),
      alpha = as.integer(alpha)/255,
      land_class = as.numeric(land_class)
    )
  
  example_ext <- ext(32e+04, 33e+04, 71.5e+04, 72.5e+04) 
  
  lcm_example_area <- 
    lcm_crop_to_study_y2022 %>%
    crop(example_ext) %>%
    as.data.table(xy = TRUE) %>%
    rename(land_class = 3) %>%
    mutate(
      is_ag_fct = if_else(
        land_class == 3, 
        "Agriculture",
        "Other"
        )
      )
  
  lcm_color_scale <- 
    lcm_palette_clean$color %>%
    purrr::set_names(lcm_palette_clean$label)
  
  lcm_example_area %>%
    
    ggplot(aes(x, y, fill = is_ag_fct)) +
    
    geom_tile() +
    scale_fill_manual(
      values = c("Agriculture" = "#1B5E20", 
                 "Other" = "#CFD8DC")
    ) +
    
    coord_fixed() +
    
    labs(
      x = "Longitude",
      y = "Latitude",
      fill = NULL,
    ) +
    
    theme_minimal() +
    theme(
      text = element_text(family = "cmr", size = 21),
      legend.position = "top"
    )
    
  }
