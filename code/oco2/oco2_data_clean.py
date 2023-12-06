# import netCDF4 as nc4
# import pydap
import requests
import xarray as xr
import pandas as pd
import matplotlib.pyplot as plt
import datetime
import cartopy.crs as ccrs

# Reading a single granule URL:
ds_xr = xr.open_dataset("H:/beavers_wildfire/oco2/raw/...")


pd_df = pd.DataFrame(columns = ["latitude", "longitude", "date_time", "xco2", "xco2_quality_flag"])

pd_df["xco2"] = ds_xr["xco2"][:]
pd_df["latitude"] = ds_xr["latitude"][:]
pd_df["longitude"] = ds_xr["longitude"][:]
pd_df["date_time"] = ds_xr["time"][:]
pd_df["xco2_quality_flag"] = ds_xr["xco2_quality_flag"][:]

pd_df["hour"] = pd.DatetimeIndex(pd_df["date_time"]).hour