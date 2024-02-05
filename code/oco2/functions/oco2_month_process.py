import os
import glob

import functions.oco2_day_process as odp

def oco2_month_process(path, year, month):

    month = "0" + str(month)

    ym_glob_str = f"oco2_LtCO2_{str(year)[2:4]}{str(month)}*.nc4"

    # List all .nc files from the specified year-month in H:/beavers_wildfire/oco2/raw 
    oco2_raw_wildcard = os.path.join(path, ym_glob_str)

    files_oco2_raw_nc_ym = glob.glob(oco2_raw_wildcard)

    res = map(odp.oco2_day_process, files_oco2_raw_nc_ym)

    return list(res)







