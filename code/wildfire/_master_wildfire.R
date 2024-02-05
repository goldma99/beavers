# ---------------------------------------------------------------------------- #
#' 
#' Description: Import and analysis wildfire data for beavers paper 
#' Author: Miriam Gold
#' Date: 13 Dec 2023
#' Last revised: date, mag
#' Notes: WFIGS
#' 
# ---------------------------------------------------------------------------- #

# Load packages ====
library(tidyverse)
library(fs)
library(sf)
library(leaflet)

# File paths ======
path_h <- 'H:/'
path_h_beavers <- file.path(path_h, "beavers_wildfire")
path_h_beavers_wfigs <- file.path(path_h_beavers, "wfigs")

path_code_beavers <- file.path("C:/Users/mGold/Desktop/beavers")

wildfires_sf <-
  path_h_beavers_wfigs %>%
  file.path("WFIGS_Interagency_Fire_Perimeters", "Perimeters.shp") %>%
  read_sf()
  

leaflet() %>%
  addPolygons(data = wildfires_sf)




