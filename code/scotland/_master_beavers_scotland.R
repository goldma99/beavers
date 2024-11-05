# ---------------------------------------------------------------------------- #
#' 
#' Description: Data importing, cleaning, and analysis related to beaver 
#' presence in Scotland
#' Author: Miriam Gold
#' Date: 4 Feb 2024
#' Last revised: date, mag
#' Notes: notes
#' 
# ---------------------------------------------------------------------------- #

# Set up ==========================================

rm(list = ls())

SOURCE_SCRIPTS <- FALSE

## Load packages ====
library(tidyverse)
library(magrittr)
library(showtext)
library(glue)
library(fs)
library(janitor)
library(lubridate)
library(httr2)
library(rvest)
library(units)

library(haven)

library(data.table)

library(sf)
library(terra)

library(fixest)

library(arrow)

library(igraph)
library(tidygraph)
library(ggraph)

## File system paths ====
path <- "C:/Users/mGold/Desktop/beavers"

path_code <- file.path(path, "code")

path_code_scotland                    <- file.path(path_code, "scotland")
path_code_scotland_functions          <- file.path(path_code_scotland, "functions")
path_code_scotland_data_clean         <- file.path(path_code_scotland, "data_clean")
path_code_scotland_data_construct     <- file.path(path_code_scotland, "data_construct")
path_code_scotland_generate_estimates <- file.path(path_code_scotland, "generate_estimates")
path_code_scotland_generate_figures   <- file.path(path_code_scotland, "generate_figures")
path_code_scotland_generate_tables    <- file.path(path_code_scotland, "generate_tables")
path_code_scotland_generate_reports   <- file.path(path_code_scotland, "generate_reports")

path_data <- file.path("H:/")

path_data_scotland             <- file.path(path_data, "beavers_scotland")
path_data_scotland_survey      <- file.path(path_data_scotland, "beaver-survey", "beaver-scotland-survey")
path_data_scotland_river       <- file.path(path_data_scotland, "river-network")
path_data_scotland_parish      <- file.path(path_data_scotland, "ag-parishes")
path_data_scotland_ukceh       <- file.path(path_data_scotland, "ukceh")
path_data_scotland_soil       <- file.path(path_data_scotland, "soil")


path_data_clean            <- file.path(path, "data", "data_clean")
path_data_clean_beaver     <- file.path(path_data_clean, "beaver_survey")
path_data_clean_parish     <- file.path(path_data_clean, "ag_parishes")
path_data_clean_hydrometry <- file.path(path_data_clean, "hydrometry")
path_data_clean_river      <- file.path(path_data_clean, "river_network")
path_data_clean_lc         <- file.path(path_data_clean, "land_cover")
path_data_clean_soil       <- file.path(path_data_clean, "soil")

path_output         <- file.path(path, "output")

path_output_figures <- file.path(path_output, "figures")
path_output_tables  <- file.path(path_output, "tables")
path_output_reports <- file.path(path_output, "reports")

setwd(path)

## Source general use custom functions
path_code_scotland_functions %>%
  dir_ls() %>%
  walk(source)

# Run entire pipeline =====================

if (SOURCE_SCRIPTS) {
  
  path_code_scotland_data_clean %>%
    file.path("_master_data_clean.R") %>%
    source()
  
  
  path_code_scotland_data_clean %>%
    file.path("_master_data_construct.R") %>%
    source()
}
