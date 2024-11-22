import zipfile
import xarray as xr 
import os


def era5_unzip(zipdir, outdir):

    print(f"Trying: {zipdir}")

    with zipfile.ZipFile(f"{zipdir}", 'r') as zip_ref:
        zip_ref.extractall(outdir)
    
    print(f"Extracted {zipdir} to {outdir}/")

def era5_aggregate_month(path):

    climate_vars = ["t2m", "tp", "lai_hv", "lai_lv"]

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
        .groupby(by=["cell_id", "latitude", "longitude", "year", "month"]) \
        .agg({"tp": "sum", "t2m": "mean", "lai_hv": "mean", "lai_lv": "mean"})
    
    return era5_month_agg
