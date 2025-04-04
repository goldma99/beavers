panel_hydrometry <- function(data, .param = c("groundwaterlevel", "flow", "level")) {
  
  param_data <- data[param == .param]
  
  switch(.param,
         groundwaterlevel = panel_hydrometry.gw(param_data),
         flow = panel_hydrometry.flow(param_data),
         level = panel_hydrometry.level(param_data))
  
}

panel_hydrometry.gw <- function(data) {

  data %>%
    dcast(
      station_id + year ~ param + measure,
      value.var = "ts_value"
    )
  
}

panel_hydrometry.flow <- function(data) {
  
  hydrometry_ts_fl_max <-
    data[
      freq == "year", 
      .(station_id, year, flow_max = ts_value)
    ]
  
  hydrometry_ts_fl_day_wide <-
    data[freq == "day"] %>%
    dcast(
      station_id + ym ~ param + measure,
      value.var = "ts_value"
    )
  
  hydrometry_ts_fl_mean <-
    hydrometry_ts_fl_day_wide[,
                              year := year(ym)
    ][,
      .(flow_mean = mean(as.numeric(flow_mean), na.rm = TRUE)),
      by = .(station_id, year)
    ]
  
  hydrometry_ts_fl_wide <-
    merge(
      hydrometry_ts_fl_max, 
      hydrometry_ts_fl_mean, 
      all = TRUE, 
      by = c("station_id", "year")
    )
  
  return(hydrometry_ts_fl_wide)
}

panel_hydrometry.level <- function(data) {
  
  hydrometry_ts_lv_wide_month <-
    dcast(
      data,
      station_id + year + month ~ param + measure,
      value.var = "ts_value"
    )
  
  hydrometry_ts_lv_wide <-
    hydrometry_ts_lv_wide_month[
      !is.na(level_max) & !is.na(level_mean),
      .(level_max = max(level_max, na.rm = TRUE),
        level_mean = mean(level_mean, na.rm = TRUE)),
      by = .(station_id, year)
    ]
  
  return(hydrometry_ts_lv_wide)
}