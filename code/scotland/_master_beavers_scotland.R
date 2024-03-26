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

library(sf)

library(glue)
library(fs)

library(igraph)
library(tidygraph)
library(ggraph)

## File system paths ====
path <- "C:/Users/mGold/Desktop/beavers"

path_code <- file.path(path, "code")
path_code_scotland <- file.path(path_code, "scotland")

path_data <- file.path("H:/")
path_data_scotland <- file.path(path_data, "beavers_scotland")
path_data_scotland_survey <- file.path(path_data_scotland, "beaver-survey", "beaver-scotland-survey")

path_data_scotland_river <- file.path(path_data_scotland, "river-network")
path_data_scotland_parish <- file.path(path_data_scotland, "ag-parishes")


## Load font ====

# Set up custom font (Computer Modern) for plots
library(showtext)
## Font (Computer Modern) for plots ====
wd <- setwd(tempdir())

ft.url <- "https://www.fontsquirrel.com/fonts/download/computer-modern/computer-modern.zip"
download.file(ft.url, basename(ft.url))
if (!file.exists("cmunrm.ttf")) unzip(basename(ft.url))

font_add("cmr", "cmunrm.ttf")
font_add("cmss", "cmunss.ttf")

showtext_auto()
showtext_opts(dpi = 300)
# Reset working directory to top level
setwd(path)


## Source all custom helper functions ====
source_dir <- function(dir, deprecated_prefix = "ZZZ") {

  str_to_ignore <- glue("^[^{deprecated_prefix}]")
  regex_to_ignore <- regex(pattern = unclass(str_to_ignore))
  
  dir_files <- fs::dir_ls(dir, recurse = TRUE, regexp = regex_to_ignore, type = "file")
  
  walk(dir_files, source)
  
  message("Sourced functions contained in:")
  fs::dir_tree(dir)
}

path_code_scotland %>%
  file.path("functions") %>%
  source_dir()

# Source individual scripts =====================

if (SOURCE_SCRIPTS) {
  
  ## Clean NatureScot repeated beaver surveys =============== 
  path_code_scotland %>%
    file.path("data_clean_beaver_scotland_survey.R") %>%
    source()
}
