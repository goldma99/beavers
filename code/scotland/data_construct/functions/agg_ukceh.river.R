agg_ukceh.river <-
  #' @description
    #' Aggregate 25m^2 LCM rasters to 1km^2 river grid cells in beaver study area
    #' This is named with the ".river" style because there's another function I wrote
    #' named `agg_ukceh()` that only deals with aggregating LCM rasters to 1km 
    #' across of Scotland, irrespective of river grid cells
  function(year, river_grid) {
    
    # Arg checks 
    stopifnot(inherits(river_grid_vector, "SpatVector"))
    stopifnot(year %in% c(1990, 2000, 2007, 2015, 2017:2022))
    
    message("Trying ", year, " ======================================")
    
    # Load year's LCM raster .tif file
    year_regex <- glue("Land Cover Map {year} ")
    lcm_path   <- str_subset(path_raster_year_list, year_regex)
    lcm_raster <- read_ukceh(lcm_path)
    
    #' The name of the land-class variable differs by year, and I need it for the 
    #' `setnames()` command below
    lc_variable <- names(lcm_raster)[1]
    
    # To reduce compute time, crop LCM raster to river grid bounding box 
    river_grid_ext  <- ext(river_grid)
    lcm_raster_crop <- crop(lcm_raster, river_grid_ext)
    
    # Link each raster cell to a river grid cell (along with its overlap weight)
    tictoc::tic(glue("extract()"))
    lcm_raster_extract <- 
      lcm_raster_crop %>%
      # crop(ext(217175, 228175, 708000, 712000)) %>%
      extract(river_grid, weights = TRUE) %>%
      setDT()
    tictoc::toc()
    message("LCM-river intersects: ", format(nrow(lcm_raster_extract), big.mark = ","))
    
    setnames(
      lcm_raster_extract,
      old = c("ID", lc_variable),
      new = c("river_id", "land_class")
      )
    
    # Mark cells as either agricultural or non-agricultural
    ag_class <- 
      if (year == 2000) {
        c(41L, 42L, 43L)
      } else {
          3L
      }
    
    lcm_raster_extract[, is_agri := as.integer(land_class %in% ag_class)]
    
    # Aggregate to river grid level: % of cell used as agricultural land
    tictoc::tic(glue("Aggregated to river grid"))
    
    river_grid_ag_share <-
      lcm_raster_extract[,
                         .(ag_share = weighted.mean(is_agri, weight)),
                         by = river_id
                         ]
    tictoc::toc()
    
    river_grid_ag_share[, year := year]
    
    # Output ======================================================
    
    # Save this year's dataset (now at river cell level) 
    filepath_ag_share <-
      path_data_clean_lc %>%
      file.path("river_ag_share", glue("river_ag_share_y{year}.pqt"))
      
    river_grid_ag_share %>%
      write_parquet(filepath_ag_share)
    
    message("Saved: ", filepath_ag_share)
    
    # Save LCM raster, cropped to study region 
    filepath_lcm_crop <-
      path_data_clean_lc %>%
      file.path("lcm_crop_to_study", glue("lcm_crop_to_study_y{year}.tif"))
      
    lcm_raster_crop %>%
      writeRaster(filepath_lcm_crop, overwrite = TRUE)
    
    message("Saved: ", filepath_lcm_crop)
    
}