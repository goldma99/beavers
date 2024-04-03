library(httr)
library(rvest)
library(sf)

url <- "https://timeseries.sepa.org.uk/KiWIS/KiWIS?service=kisters&type=queryServices&datasource=0&request=getStationList"

resp <- GET(url)

hydrometry_stations <-
  rawToChar(resp$content) %>%
  read_html() %>%
  html_table(header = 1) %>%
  pluck(1)

hydrometry_stations_sf <-
  hydrometry_stations %>%
  filter(!is.na(station_latitude)) %>%
  st_as_sf(
    coords = c("station_longitude", "station_latitude"),
    crs = 4326
  )

hydrometry_stations_in_survey <-
  hydrometry_stations_sf %>%
  st_transform(crs = 27700) %>%
  st_filter(ag_parish_in_survey) 

ggplot() +
  geom_sf(data = ag_parish_in_survey) +
  geom_sf(data = beaver_survey_sf) +
  geom_sf(data = hydrometry_stations_in_survey, color = "red")
