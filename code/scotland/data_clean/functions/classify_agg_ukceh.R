classify_agg_ukceh <- function(rast) {
  
  stopifnot(length(names(rast))==1)
  
  .year <- names(rast)
  
  lcm_replace_mat <- 
    lcm_class_crosswalk[
      year == .year, 
      .(class_no, agg_class_no)
      ]
  
  classify(rast, lcm_replace_mat)

  }
