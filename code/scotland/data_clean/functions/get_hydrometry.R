hydrometry_get <- function(
  request = c("site", "station", "parameter", "parameter_type", "timeseries", "timeseries_type", "timeseries_values", "timeseries_value_layer", "quality_codes"),
  ...
  ) {
  
  request   <- match.arg(request)
  
  hydrometry_build_req(request, ...) %>%
    req_perform() %>%
    hydrometry_parse()

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
