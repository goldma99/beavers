
import os
import stat
import cdsapi

# Constants 
dataset = "reanalysis-era5-land"
targetdir = "H:/beavers_scotland/era5/"
variables = [
        "2m_temperature",
        "total_precipitation",
        "leaf_area_index_high_vegetation",
        "leaf_area_index_low_vegetation"
        ]

days = [f"{i:02}" for i in range(1,32)]
times = [f"{i:02}:00" for i in range(0, 24)]

for year in [y for y in range(1998, 2023)]:
    for month in [f"{i:02}" for i in range(1, 13)]:
        # Request params 
        request = {
            "variable": variables,
            "year": year,
            "month": month,
            "day": days,
            "time": times,
            "data_format": "netcdf",
            "download_format": "zip",
            "area": [59, -7, 54, -1]
        }

        # Execute request and download zip file

        # tpv = temperature, precip, veg 
        zipname = f"era5_tpv_{year}{month}.zip"

        client = cdsapi.Client()
        client.retrieve(dataset, request).download(f"{targetdir}/{zipname}")


