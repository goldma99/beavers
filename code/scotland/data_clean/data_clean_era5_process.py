# =====================================================================
# Description: Aggregate ERA5 climate data to annual level
# Author: Miriam Gold
# Last revised: 24 October 2024
# Notes:
# 
# =====================================================================

# Set up ============================

## Libraries ================
import xarray as xr 

import zipfile
import os
import glob 
import re 

import matplotlib.pyplot as plt
import pandas as pd

import functions.era5_process as proc

## File paths ================
path_era5 = "H:/beavers_scotland/era5"
path_era5_clean = "H:/beavers_scotland/era5_clean"
path_era5_clean_m = f"{path_era5_clean}/monthly"
path_era5_clean_y = f"{path_era5_clean}/yearly"

## Global settings ==========
UNZIP = False
MONTH_AGG = False
YEAR_AGG = True

# Process ERA5 climate data ====================
years = [y for y in range(2015, 2023)]

for year in years:

    ## Unzip ERA5 year-month directories ==============
    if UNZIP:
        year_files_zip = glob.glob(f"{path_era5}/*{year}*.zip")
        for y_zip in year_files_zip:
            y_out = y_zip.replace(".zip", "/")
            proc.era5_unzip(y_zip, y_out)
    
    month_dirs = glob.glob(f"{path_era5}/*{year}*/")

    ## Aggregate from hourly to monthly data at the ERA5 grid cell level =====
    if MONTH_AGG:
        for m_dir in month_dirs:

            path_ym_data = os.path.join(m_dir, "data_0.nc")
            m_agg = proc.era5_aggregate_month(path_ym_data)
        
            m_match = re.search("era5_tpv_\d{4}(\d{2})", m_dir)
            if m_match:
                month = m_match.group(1)
            path_out = os.path.join(path_era5_clean_m, f"era5_tpv_{year}{month}.pqt")
            m_agg.to_parquet(path_out) 
            print("Saved: ", path_out)


## Bind monthly data and aggregate to yearly level ============
if YEAR_AGG:
    list_month_files = [os.path.join(path_era5_clean_m, f) for f in os.listdir(path_era5_clean_m)]
    data_year_rbind = pd.concat([pd.read_parquet(f) for f in list_month_files]) 
    data_year_rbind = data_year_rbind.reset_index()
    
    era5_year_agg = data_year_rbind \
        .groupby(by=["cell_id", "year"]) \
        .agg({"tp": "sum", "t2m": "mean", "lai_hv": "mean", "lai_lv": "mean"}) \
        .reset_index()
    
    path_out_annual = os.path.join(path_era5_clean_y, "era5_tpv_annual.pqt")

    era5_year_agg.to_parquet(path_out_annual)
    

    
