#!/bin/bash

curl -o H:\\beavers_wildfire\\oco2\\raw\\oco2_LtCO2_170925_B11100Ar_230601222611s.nc4 \
     -b ~/.urs_cookies \
     -c ~/.urs_cookies \
     -L -J -n https://data.gesdisc.earthdata.nasa.gov/data/OCO2_DATA/OCO2_L2_Lite_FP.11.1r/2017/oco2_LtCO2_170925_B11100Ar_230601222611s.nc4
