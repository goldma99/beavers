agg_ukceh.river <-
  #' @description
    #' Aggregate 25m LCM rasters to 1km^2 river grid cells in beaver study area
    #' This is named with the ".river" style because there's another function I 
    #' wrote named `agg_ukceh()` that only deals with aggregating LCM rasters to 
    #' 1km across of Scotland, irrespective of river grid cells
  function(year, river_grid) {
    
    # Arg checks 
    stopifnot(inherits(river_grid, "SpatVector"))
    stopifnot(year %in% c(1990, 2000, 2007, 2015, 2017:2022))
    
    message("Trying ", year, " ======================================")
    
    # Load year's LCM raster .tif file
    year_regex <- glue("Land Cover Map {year} ")
    lcm_path   <- str_subset(path_raster_year_list, year_regex)
    
    tictoc::tic(glue("Reading {lcm_path}"))
    lcm_raster <- read_ukceh(lcm_path)
    tictoc::toc()
    
    # To reduce compute time, crop LCM raster to river grid bounding box 
    lcm_raster_crop <- crop(lcm_raster, ext(river_grid))
    
    # Convert granular classes to aggregate, temporally consistent classes
    lcm_raster_agg_class <- classify_agg_ukceh(lcm_raster_crop)
    
    # Link each raster cell to a river grid cell (along with its overlap weight)
    tictoc::tic(glue("extract()"))
    
    lcm_raster_extract <- 
      lcm_raster_agg_class %>%
      extract(river_grid, weights = TRUE) %>%
      setDT()
    
    tictoc::toc()
    
    message("LCM-river intersects: ", 
            format(nrow(lcm_raster_extract), big.mark = ","))
    
    setnames(
      lcm_raster_extract,
      old = c("ID"      , names(lcm_raster)[1]),
      new = c("river_id", "land_class")
      )
    
    # Aggregate to river grid level: % of cell used as agricultural land
    tictoc::tic("Aggregated to river grid")
    
    lcm_classes <-
      lcm_agg_class_crosswalk %>% 
      pull(agg_class_no) %>% 
      unique() %>% 
      sort()
    
    lcm_class_vars <- paste0("is_land_class_", lcm_classes)
    
    lcm_raster_extract[,
                       (lcm_class_vars) := lapply(lcm_classes,
                                                  \(c) land_class == c)
                       ]
    
    river_grid_lcm_shares <-
      lcm_raster_extract[,
                         lapply(.SD, \(x) weighted.mean(x, weight, na.rm = TRUE)),
                         .SDcols = lcm_class_vars,
                         by = river_id
                         ]
    
    river_grid_lcm_shares[, year := year]
    
    tictoc::toc()
    
    # Output ======================================================
    
    ## 1km-agg'd grid
    filepath_lcm_shares <-
      path_data_clean_lc %>% 
      file.path("grid1km_lcm_shares", glue("grid1km_lcm_shares_y{year}.pqt")) 
    
    river_grid_lcm_shares %>%
      write_parquet(filepath_lcm_shares)
    
    message("Saved: ", filepath_lcm_shares)
    
    ## Cropped and land-class harmonized LCM raster 
    filepath_lcm_crop <-
      path_data_clean_lc %>%
      file.path("lcm_crop_to_study", glue("lcm_crop_to_study_y{year}.tif"))
      
    lcm_raster_agg_class %>%
      writeRaster(filepath_lcm_crop, overwrite = TRUE)
    
    message("Saved: ", filepath_lcm_crop)
    
}