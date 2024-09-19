read_ukceh <- function(path) {
  
  rast_obj        <- terra::rast(path)
  land_class_band <- names(rast_obj)[1]
  rast_lc_band    <- rast_obj[[land_class_band]]
  
  return(rast_lc_band)
  
}