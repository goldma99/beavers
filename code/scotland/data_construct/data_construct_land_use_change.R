# Set up ==========================================
library(stars)
library(raster)
library(tidyterra)


# Read in data ====================================

lcm_class_crosswalk <-
  path_data_clean_lc |>
  file.path(
    "agg_class_crosswalk", 
    "agg_class_crosswalk.csv"
  ) |>
  read_csv(show_col_types = FALSE) |>
  mutate(
    agg_class_no = if_else(!agg_class_no %in% c(1, 2, 3), NA, agg_class_no)
  ) |>
  setDT()

rast_list <-
  path_raster_year_list |>
  map(read_ukceh)

# Clean data ======================================
rast_cropped <-
  rast_list |>
  map(
    ~crop(
      .x, 
      ext(
        3.05e+05, 
        4.25e+05, 
        7.20e+05,
        8.35e+05
      )
    )
  )

rast_reclass <- map(rast_cropped, classify_agg_ukceh)

rast_c <- reduce(rast_reclass, c)

varnames(rast_c) <- rep("LCM", 10)

time(rast_c) <- 
  c(1990, 2000, 2007, 2015, 2017:2022) |>
  paste("-01-01") |>
  as_date()

rast_stars <-
  rast_c |>
  st_as_stars()

names(rast_stars) <- "LCM"

# Analysis ========================================

# Output ==========================================

plot(rast_stars)

rast_stars |>
  stars::as.tbl_cube.stars() |>
  group_by(x,y) |>
  summarise(
    lcm_max = max(LCM)
  )