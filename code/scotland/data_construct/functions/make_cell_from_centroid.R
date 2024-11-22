make_cell_from_centroid <- 
  function(point, w = 0.25) {
    d <- w/2
    
    p_mat <- 
      rep(st_coordinates(point), 5) %>%
      matrix(ncol = 2, byrow = TRUE)
    
    trans_mat <- 
      c(d,d, -d,d, -d,-d, d,-d, d, d) %>% 
      matrix(ncol = 2, byrow = TRUE) 
    
    st_polygon(list(p_mat + trans_mat))
    
  }

