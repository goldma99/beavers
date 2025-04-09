aggregate_panel_2period <- function(data, ...) {
  
    
  cohorts <- unlist(rlang::list2(...))
  
  cohorts_named <- paste0("g", cohorts)
  
  cohort_treatments <-
    list(
      g1 = list(pre_end = 2000, post_start = 2012),
      g2 = list(pre_end = 2012, post_start = 2017),
      g3 = list(pre_end = 2017, post_start = 2020)
    )

  treated_thresholds <- 
    cohort_treatments[cohorts_named] %>% 
    unlist() %>% 
    range()
  
  panel_cohorts <- data[g %in% c(0, cohorts)] 
  
  panel_cohorts[, 
                 t := fcase(
                   year <= treated_thresholds[1], 0,
                   year >= treated_thresholds[2], 1
                   )
                 ]  
  
  panel_cohorts_nona <- panel_cohorts[!is.na(t)]
  
  unique_cols <- str_subset(names(data), "^g$|lccd_mj_dom|soil_share_|on_river")
  mean_cols   <- str_subset(names(data), "_?mean_?|_max|is_land_class")

  panel_2period <-
    panel_cohorts_nona[,
                       c(
                         map(.SD[, unique_cols, with = FALSE], ~ unique(.x, na.rm = TRUE)),
                         map(.SD[, mean_cols  , with = FALSE], ~ mean(.x, na.rm = TRUE))
                         ),
                       by = .(river_id, t)
                       ][, 
                         beaver_d := fifelse(
                           g == 0 | t == 0,
                           0,
                           1
                           )
                         ][]
  
  return(panel_2period)
  
}
