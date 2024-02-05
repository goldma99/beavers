'''
Description: Read in raw OCO2 data and filter it to bounding box, 
             then append daily datasets and save in monthly files, within
             year-by-year directories in ../oco2/intermediate
Author: Miriam Gold
Date: 8 Dec 2023
Last revised: date, mag
Notes:
'''

# Import packages ----------------------------

## File system ---------------
import glob 
import os
import pandas as pd 
import itertools 

## Custom functions ----------
from functions import oco2_month_process as omp

# File paths ----------------------------
path_drive_h = "H:\\"
path_beavers = os.path.join(path_drive_h, "beavers_wildfire")
path_data_oco2 = os.path.join(path_beavers, "oco2")
path_data_oco2_raw = os.path.join(path_data_oco2, "raw")
path_data_oco2_int = os.path.join(path_data_oco2, "intermediate")


# Apply function to all oco2 files in H:/.../oco2/raw)
yr_range = range(2014, 2023)
m_range = range(1, 13)

ym_month_list = list(itertools.product(yr_range, m_range))

ym_tuples = [(y,m) for (y,m) in ym_month_list if m > 8 or y > 2014]

# Create directories for each year's cleaned monthly data
for year in yr_range:
    year_dir = os.path.join(path_data_oco2_int, str(year))
    try:
        os.mkdir(year_dir)
    except FileExistsError:
        print(f"{year} directory already exists")

# Clean and save every month's-worth of data from Sep 2014 to Dec 2022
for ym in ym_tuples[34:]:
    ym_res_list = omp.oco2_month_process(path_data_oco2_raw, *ym)

    y, m = ym

    if len(ym_res_list):
        # Row-bind the month's daily datasets 
        ym_res_concat = pd.concat(ym_res_list)

        # Write month dataset to disk
        filename = f"oco2_cleaned_{str(y)}0{str(m)}.pqt"
        dest_path = os.path.join(path_data_oco2_int, str(y), filename)
        ym_res_concat.to_parquet(dest_path)