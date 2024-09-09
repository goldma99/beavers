
process_ukceh <- function(path) {
  
  year     <- str_extract(path, "Land Cover Map (\\d{4}) ", group = 1)
  out_path <- file.path(path_data_clean_lc, glue("ukceh_lcm_1km_{year}.tif"))
  
  message("Trying: ", year, "\n")
  
  rast_ukceh <- read_ukceh(path)
  rast_agg   <- agg_ukceh(rast_ukceh)
  
  writeRaster(rast_agg, out_path, overwrite = TRUE)
  
  message("Saved: ", out_path, "\n")
  
}

read_ukceh <- function(path) {
  
  rast_obj        <- terra::rast(path)
  land_class_band <- names(rast_obj)[1]
  rast_lc_band    <- rast_obj[[land_class_band]]
  rast_trim <- terra::trim(rast_lc_band)
  
  return(rast_trim)
  
}

agg_ukceh <- function(rast) {
  
    if (terra::varnames(rast) == "LCM2000") {
      agg_fn <- class_share_ag.2000
      message("Using the following ag class values: 41, 42, 43")
    } else {
      agg_fn <- class_share_ag
      message("Using the following ag class values: 3")
    }
  
  rast_agg <- 
    terra::aggregate(
      rast,
      # Aggregate by a factor of 40 (25m * 40 = 1000m = 1km) to match river grid size
      fact = 40,
      fun = agg_fn
    )
  
  return(rast_agg)

  }

# Default land class value for arable/horitculture is usually 3...
class_share_ag <- function(x, lc = 3) {
  
  n    <- length(x)
  x_lc <- length(x[x %in% lc])
  
  x_lc/n
}

#...but LCM 2000 has abnormal coding, so its arable/horticulture codes are 41, 42, 43
class_share_ag.2000 <- function(x) {
  class_share_ag(x, c(41, 42, 43))
}
