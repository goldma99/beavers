read_geography <- function(dir) {
  
  filename <- glue::glue("{basename(dir)}.shp")
  
  filepath <- file.path(dir, filename)
  
  sf::read_sf(filepath)
  
}