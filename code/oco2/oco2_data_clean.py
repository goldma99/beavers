# import netCDF4 as nc4
# import pydap
import requests
import xarray as xr
import pandas as pd
import matplotlib.pyplot as plt
import datetime
import cartopy.crs as ccrs

# List all .nc files in H:/beavers_wildfire/oco2/raw


# Function:
#   Reads in single day's file and converts it to dataframe, 
#   Trim to a bounding box
#   Return as pandas dataframe object to environment


# Apply function to all oco2 files in H:/.../oco2/raw
# Append each month's files? If this doesn't create a huge file, I'd support it
#   Otherwise, keep at the daily level and save as parquet files in H:/.../oco2/intermediate/

oco2_nc4 = xr.open_dataset("H:/beavers_wildfire/oco2/raw/...")


oco2_df = pd.DataFrame(columns = ["latitude", "longitude", "date_time", "xco2", "xco2_quality_flag"])

oco2_df["xco2"] = oco2_nc4["xco2"][:]
oco2_df["latitude"] = oco2_nc4["latitude"][:]
oco2_df["longitude"] = oco2_nc4["longitude"][:]
oco2_df["date_time"] = oco2_nc4["time"][:]
oco2_df["xco2_quality_flag"] = oco2_nc4["xco2_quality_flag"][:]

oco2_df["hour"] = pd.DatetimeIndex(oco2_df["date_time"]).hour