read_ukceh <- function(path) {
  
  year <- str_extract(path, "Map (\\d{4})", group = 1)
  
  rast_obj        <- terra::rast(path)
  land_class_band <- names(rast_obj)[1]
  rast_lc_band    <- rast_obj[[land_class_band]]
  rast_trim <- terra::trim(rast_lc_band)
  
  names(rast_trim) <- year
  
  return(rast_trim)
  
}