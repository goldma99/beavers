hydrometry_get <- function(
  request = c("site", "station", "parameter", "parameter_type", "timeseries", "timeseries_type", "timeseries_values", "timeseries_value_layer", "quality_codes"),
  ...
  ) {
  
  request   <- match.arg(request)
  
  hydrometry_req <- hydrometry_build_req(request, ...) 

  resp_data <-
    hydrometry_req %>%
    req_perform() %>%
    hydrometry_parse()
  
  message("Received: ", hydrometry_req$url)
  
  if (request == "timeseries_values") {
    timeseries_values_clean(resp_data)
  } else {
    resp_data
  }

  }

hydrometry_build_req <- function(request, format, ...) {
  
  queryfields <- rlang::list2(...)
  
  request_header <- 
    switch(request,
           "site"                   = "getSiteList", 
           "station"                = "getStationList", 
           "parameter"              = "getParameterList",
           "parameter_type"         = "getParameterTypeList",
           "timeseries"             = "getTimeseriesList", 
           "timeseries_type"        = "getTimeseriesTypeList", 
           "timeseries_values"      = "getTimeseriesValues", 
           "timeseries_value_layer" = "getTimeseriesValueLayer", 
           "quality_codes"          = "getQualityCodes")

  base_url <- "https://timeseries.sepa.org.uk/KiWIS/KiWIS" 
  
  req_headers <-
    list(
      service = "kisters",
      type = "queryServices",
      format = "html",
      datasource = "0",
      request = request_header
    )
  
  req_base <- request(base_url)
  
  req_url_query(req_base, !!!req_headers, !!!queryfields)
  
  }

check_response <- function(resp) {}

hydrometry_parse <- function(resp) {
  resp %>%
    httr2::resp_body_html() %>%
    rvest::html_table(header = 1) %>%
    purrr::pluck(1)
}

timeseries_values_clean <- function(resp_data) {
  resp_data %>% 
    set_names(c("timestamp", "value", "quality_code")) %>%
    slice(4:n()) %>% 
    mutate(
      ts_id = names(resp_data)[2]
    )
}
