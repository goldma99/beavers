import zipfile
import xarray as xr 
import os


def era5_unzip(zipdir, outdir):

    with zipfile.ZipFile(f"{zipdir}", 'r') as zip_ref:
        zip_ref.extractall(outdir)
    
    print(f"Extracted {zipdir}.zip to {outdir}/")

# TODO: Add lai_lv variable
def era5_aggregate_month(path):

    climate_vars = ["t2m", "tp", "lai_hv"]

    # Read in dataset
    era5_xr = xr.open_dataset(path)
    era5_df = era5_xr.to_dataframe()
    era5_df = era5_df[climate_vars].reset_index()

    # Clean time variables 
    era5_df["year"]  = era5_df.valid_time.dt.year
    era5_df["month"] = era5_df.valid_time.dt.month
    era5_df["day"]   = era5_df.valid_time.dt.day
    era5_df["hour"]  = era5_df.valid_time.dt.hour

    # Create spatial id variable
    era5_df = era5_df.round({"longitude": 2, "latitude": 2})
    era5_df["cell_id"] = era5_df.longitude.astype(str) \
                            + "," \
                            + era5_df.latitude.astype(str)

    # Convert units 
    era5_df["tp"]  = era5_df["tp"]*1000      ## Precip: m to mm
    era5_df["t2m"] = era5_df["t2m"] - 273.15 ## Temp: K to C

    # sum precip to monthly, then average yearly
    # temp: avg daily temp, then DD bins (relative to 18c?)
    # lai: mean monthly

    era5_month_agg = era5_df \
        .groupby(by=["cell_id", "year", "month"]) \
        .agg({"tp": "sum", "t2m": "mean", "lai_hv": "mean"})
    
    return era5_month_agg



# # !/software/python-anaconda-2020.02-el7-x86_64/bin/python

# # ==================================================================================================
# # Description: For RD country border analysis, aggregate precip to monthly sums by ERA5 grid cell
# # Author: Miriam Gold
# # Date: 25 June 2024
# # Notes:
# # ==================================================================================================

# # Set up =============================================================

# ## Load packages ========================
# import numpy as np
# import pandas as pd
# import xarray as xr

# import geopandas as gpd
# import rioxarray
# from shapely.geometry import mapping
# from shapely.geometry import box
# from fiona.crs import from_epsg

# from pathlib import Path
# import os
# import re

# ## File paths =============================
# path             = '/project2/amirjina/'
# path_locust_proj = path + 'locust-project/'
# path_data        = path_locust_proj + 'data/'
# path_data_raw    = path_data + 'raw/'
# path_data_int    = path_data + 'intermediate/'

# path_precip_monthly = path_data_int + 'precip_monthly_0p25/'

# if not os.path.exists(path):
#     os.chdir('/Volumes/project2/amirjina/')

# os.chdir(path)

# if not os.path.exists(path_precip_monthly):
#     os.mkdir(path_precip_monthly)


# # Read in data =============================================================

# ## Bounding box of study region ======================
# cluster_poly = gpd.read_file(path_data_raw + 'dhs_cluster_with_buffers/150km/dhs_cluster_buffer_150km.shp')
# cluster_poly_bbox = box(*cluster_poly.geometry.total_bounds)
# cluster_box_polygon = gpd.GeoDataFrame({'geometry': cluster_poly_bbox}, 
#                                        index=[0], 
#                                        crs="epsg:4326")


# ## Daily precipitation at 0.25-deg resolution ======================

# precip_dir = path + "/climate_data/intermediate/era5_0p25_daily_precip_LT/"

# precip = sorted(Path(precip_dir).glob("*.nc"), key=os.path.getmtime)

# # We need data from January 1985 (to match FAO locust time range); find its index
# precip_start = sorted(Path(precip_dir).glob("*1985_1.nc"), key=os.path.getmtime)
# start_index = precip.index(precip_start[0])


# ## Aggregate precip to monthly totals by 0.25-deg grid cell ===========================

# for month in range(len(precip)-start_index):

#     # We want the current month, but also the previous month, since it contains this month's first day's data
#     index_current_month  = start_index + month
#     index_previous_month = index_current_month-1

#     # Read in current month's data
#     daily_current_month = xr.open_dataset(precip[index_current_month])

#     # Each month n contains the first day of month n+1's data, which we remove here
#     daily = daily_current_month.isel(time = slice(0, -1))

#     daily.rio.write_crs("epsg:4326", inplace=True)

#     daily_clipped = daily.rio.clip(cluster_box_polygon.geometry.apply(mapping), 
#                                 all_touched=True, 
#                                 drop=True)
    
#     daily_clipped = daily_clipped.to_dataframe().reset_index()

#     daily_clipped['year'] = daily_clipped.time.dt.year
#     daily_clipped['month'] = daily_clipped.time.dt.month

#     # Extract first day of month n from month n-1's dataset
#     daily_previous_month = xr.open_dataset(precip[index_previous_month])
#     daily_first_day = daily_previous_month.isel(time = -1)
#     daily_first_day.rio.write_crs("epsg:4326", inplace=True)
#     clipped_first_day = daily_first_day.rio.clip(cluster_box_polygon.geometry.apply(mapping), all_touched=True, drop=True)
#     clipped_first_day = clipped_first_day.to_dataframe().reset_index()
#     clipped_first_day['year'] = clipped_first_day.time.dt.year
#     clipped_first_day['month'] = clipped_first_day.time.dt.month

#     # Append first day and rest of month's data
#     full_month = clipped_first_day.append(daily_clipped)   

#     # Convert m to mm of precip per day
#     full_month['tp'] = full_month['tp']*1000

#     # Aggregate to monthly sums by grid cell
#     monthly = full_month.groupby(by=['latitude', 'longitude', 'year', 'month']).sum().reset_index()

#     # Ensure every dataset has the exact same columns
#     monthly = monthly.drop(columns = 'spatial_ref')
#     monthly = monthly[['latitude','longitude','year','month', 'tp']]
    
#     # Write to parquet file (.pqt used for space efficiency)
#     filename_current_month = precip[index_current_month].stem
#     year, month = re.search('daily_total_precipitation_(\\d{4})_(\\d{1,2})', filename_current_month).group(1, 2)

#     year_dir = path_precip_monthly + f"{year}/" 

#     if not os.path.exists(year_dir):
#         os.mkdir(year_dir)

#     path_cell_ym = year_dir + f"monthly_precip_0p25_{year}_{month}.pqt"
#     monthly.to_parquet(path_cell_ym)

#     print(f"Saved: {path_cell_ym}")