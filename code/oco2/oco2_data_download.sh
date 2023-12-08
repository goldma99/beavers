#############################################
# Description: Download OCO2 data from NASA
# Author: Miriam Gold
# Date: 5 Dec 2023
# Last revised: 8 Dec 2023
# Notes: 
#############################################


#!/bin/bash

# Set location of beavers project directory on local machine 
cd "C:\Users\mGold\Desktop\beavers"

# Read in all file paths for downloading
input="$PWD\data\helper_data\subset_OCO2_L2_Lite_FP_11.1r_20231206_042328_.txt"
mapfile FILES < $input

# Download each file 
for fileurl in ${FILES[@]}; 
do
    filename=$(basename $fileurl)

    echo "Trying: $filename"
    
    eval "curl -o H:/beavers_wildfire/oco2/raw/$filename \
               -b ~/.urs_cookies \
               -c ~/.urs_cookies \
               -L -J -n $fileurl"
    
    echo "--------------------------------------------------"
               
done
