/*
   Description: Read in estimates results and convert them to dataframes so I can work with them in R
   Author: Miriam Gold
   Date: 9 April 2025
   Last revision: revise-date
   Notes: notes
*/

********************************************************************************
// Setup -----------------------------------------------------------------------
********************************************************************************
cap log close
clear all
set more off, permanently
set matsize 11000
set maxvar 32767
set scheme s1mono
set mem 70m

confirmdir "D:/Dropbox/Research/beavers"
if r(confirmdir) == "0" {
  local rootDir = "D:/Dropbox/Research/"
}
else {
    di as error "D:/Dropbox/Research directory not found"
    exit 198
}

// File paths -------------------------------------
global path "`rootDir'/beavers"
global path_data "$path/data"

global path_data_treatment "$path_data/data_clean/treatment"
global path_data_est       "$path_data/estimates"


// Regression globals -------------------------------------------
global samples_cohort ///
       g1 ///
       g2 ///
       g3 ///
       g12 ///
       g13 ///
       g23 ///
       g123

global samples_river ///
       all_cells ///
       river_cells ///
       non_river_cells

global samples_soil ///
       all_soil ///
       AC ///
       IGRG ///
       NAG

global dep_vars ///
       is_land_class_1 ///
       is_land_class_2 ///
       is_land_class_3 ///
       is_land_class_4 ///
       is_land_class_5 ///
       is_land_class_6 ///
       is_land_class_7 ///
       is_land_class_8 ///
       is_land_class_9 ///
       is_land_class_10 ///
       level_mean ///
       level_max ///
       flow_mean

global indep_vars beaver_d

global fes twfe

global control_sets no_controls weather_controls
global no_controls
global weather_controls tp_mean t2m_mean

********************************************************************************
// 1. Convert .ster files to csv files -----------------------------------------
********************************************************************************

foreach sample_cohort in $samples_cohort {
    foreach sample_river in $samples_river {
        foreach sample_soil in $samples_soil {
            foreach dep_var in $dep_vars {
                foreach indep_var in $indep_vars {
                    foreach fe in $fes {
                        foreach cl in river_id {
                            foreach control_set in $control_sets {

                            	local filename est_beaver_DV`dep_var'_TV`indep_var'_S`sample_cohort'_`sample_river'_`sample_soil'_C`control_set'_FE`fe'_CL`cl'
                                capture noisily {
                                	estimates use $path_data_est/`filename'.ster
                                }
                                if _rc != 0 {
                                	continue
                                }
                                else {
	                                parmest, fast
    	                            export delimited using $path_data_est/`filename'.csv, replace	
                                }
                                
                            }
                        }
                    }
                }
            }
        }
    }
}
