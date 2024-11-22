# ---------------------------------------------------------------------------- #
#' 
#' Description: Generate figures for Scotland beavers paper
#' Author: Miriam Gold
#' Date: 28 Sept 2024
#' Last revised: date, mag
#' Notes: notes
#' 
# ---------------------------------------------------------------------------- #

# Set up ==========================================

SOURCE_SCRIPTS <- FALSE

## Source block-specific custom functions ====
path_code_scotland_generate_figures %>%
  file.path("plotting_functions") %>%
  source_dir()

## Load font ====

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
setwd(path_code_scotland_generate_figures)

# Source individual scripts =====================

if (SOURCE_SCRIPTS) {
  
  ## Beaver survey plots ======================
  path_code_scotland_generate_figures %>%
    file.path("plot_generate_beavers.R") %>%
    source()
  
  ## Land use plots ======================
  path_code_scotland_generate_figures %>%
    file.path("plot_generate_land_use") %>%
    source()
  
}