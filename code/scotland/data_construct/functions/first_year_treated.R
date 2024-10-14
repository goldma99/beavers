first_year_treated <- 
  #' @description
    #' Determine first year of an absorbing treatment
  #' @param y vector of time periods
  #' @param x vector of treatment status
  #' @param d value that denotes unit is treated
  function(y, x, d = 1) {
  
  if (purrr::is_empty(which(x == d))) {
    return(NA_integer_)
  } else {
    first_d <- min(which(x == d))
    y[first_d]
  }
  }

