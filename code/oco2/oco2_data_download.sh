#!/bin/bash
input="$PWD\data\helper_data\subset_OCO2_L2_Lite_FP_11.1r_20231206_042328_.txt"
mapfile FILES < $input

for fileurl in ${FILES[0]}; 
do
    filename=$(basename $fileurl)

    echo "Trying: $filename"
    
    eval "curl -o H:/beavers_wildfire/oco2/raw/$filename \
               -b ~/.urs_cookies \
               -c ~/.urs_cookies \
               -L -J -n $fileurl"
    
    echo "--------------------------------------------------"
               
done
