read_treatment_panel <- 
  function(
    sample = c("overall", "g1", "g2")
  ) {
    
    sample <- match.arg(sample)
    
    path_data_clean %>%
      file.path(
        "treatment",
        glue("river_grid_panel_2period_{sample}.pqt")
      ) %>%
      read_parquet()
  }
