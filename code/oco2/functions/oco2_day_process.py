
# Import packages ----------------------------
## Data import ---------------
import xarray as xr
import pandas as pd
import datetime
## Geospatial ---------------
# import cartopy.crs as ccrs
import geopandas
import shapely

# Functions:

def oco2_day_process(path: str):
    oco2_df = oco2_day_import(path)
    return oco2_day_trim(oco2_df)

def oco2_day_import(path: str):
    
    # Reads in single day's file and converts it to dataframe, 
    oco2_nc4 = xr.open_dataset(path)

    #   Return as pandas dataframe object to environment
    oco2_df = pd.DataFrame(columns = ["latitude", "longitude", "date_time", "xco2", "xco2_quality_flag"])

    oco2_df["xco2"] = oco2_nc4["xco2"][:]
    oco2_df["latitude"] = oco2_nc4["latitude"][:]
    oco2_df["longitude"] = oco2_nc4["longitude"][:]
    oco2_df["date_time"] = pd.to_datetime(oco2_nc4["time"][:])
    oco2_df["xco2_quality_flag"] = oco2_nc4["xco2_quality_flag"][:]
    
    oco2_df["year"] = oco2_df["date_time"].dt.year
    oco2_df["month"] =oco2_df["date_time"].dt.month
    oco2_df["day"] = oco2_df["date_time"].dt.day

    return oco2_df

def oco2_day_trim(data: pd.DataFrame):
    # Convert to geodataframe
    oco2_geo = geopandas.GeoDataFrame(data,
                                      geometry=geopandas.points_from_xy(data.longitude, data.latitude),
                                      crs="EPSG:4326")

    # Trim to a bounding box
    xmin, xmax, ymin, ymax = (-124.24, -102.03,  33.55, 49.15)
    oco2_geo_trimmed = oco2_geo.cx[xmin:xmax, ymin:ymax]
    oco2_trimmed = oco2_geo_trimmed.drop(columns="geometry")

    # Check if there were any obs in bounding box
    nrow = oco2_geo_trimmed.shape[0]

    if nrow == 0:
        print("No data in day, moving on")
        oco2_geo_empty = oco2_geo[:0].drop(columns="geometry")
        return oco2_geo_empty
    else:
        return oco2_trimmed