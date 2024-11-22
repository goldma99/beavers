/*
   Description: Generate main specifications of outcome ~ beaver entry
   Author: Miriam Gold
   Reviewer: name
   Last revised: 27 Oct 2024, mag
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

confirmdir "C:/Users/mGold"
if r(confirmdir) == "0" {
  local rootDir = "C:/Users/mGold/Desktop"
}
else {
    di as error "C:/Users/mGold directory not found"
}

// File paths -------------------------------------
global path "`rootDir'/beavers"
global path_data "$path/data"

global path_data_treatment "$path_data/data_clean/treatment"
global path_data_est       "$path_data/estimates"

// Regression globals -------------------------------------------
global samples_cohort ///
       overall ///
       g2 ///
       g1

global samples_river ///
       all_cells ///
       river_cells

global samples_soil ///
       all_soil ///
       AC ///
       IGRG ///
       NAG

global dep_vars ///
       ag_share ///
       level_mean ///
       level_max ///
       flow_mean

global indep_vars beaver_d

global fes twfe

global control_sets no_controls weather_controls
global no_controls
global weather_controls tp_mean t2m_mean

********************************************************************************
// 1. Read in data -------------------------------------------------------------
********************************************************************************

foreach sample_cohort in $samples_cohort {
    mkf S`sample_cohort'
    cwf S`sample_cohort'
    use $path_data_treatment/river_grid_panel_2period_`sample_cohort'
}

********************************************************************************
// 2. Run Regressions ----------------------------------------------------------
********************************************************************************

foreach sample_cohort in $samples_cohort {
    foreach sample_river in $samples_river {
        foreach sample_soil in $samples_soil {
            foreach dep_var in $dep_vars {
                foreach indep_var in $indep_vars {
                    foreach fe in $fes {
                        foreach cl in river_id {
                            foreach control_set in $control_sets {

                                cwf S`sample_cohort'

                                if "`sample_river'" == "all_cells" {
                                    local sample_restriction 1 
                                }
                                else if "`sample_river'" == "river_cells" {
                                    local sample_restriction on_river == 1
                                }
                                else {
                                    di as error "Unsupported sample_river value: `sample_river'"
                                    exit(198)
                                }

                                if "`sample_soil'" == "all_soil" {
                                    local sample_restriction `sample_restriction' & 1
                                }
                                else {
                                    local sample_restriction `sample_restriction' & lccd_mj_dom == "`sample_soil'"
                                }

                                if "`fe'" == "twfe" {
                                    local fe_set river_id t_`sample_cohort'
                                }
                                else {
                                    di as error "Unsupported fe value: `fe'"
                                }

                                ** Regression ---------------------------------- 
                                reghdfe `dep_var' `indep_var' $`control_set' if `sample_restriction', ///
                                        absorb(`fe_set') ///
                                        cluster(`cl')

                                estadd ysumm
                                estadd local sample_cohort "`sample_cohort'"
                                estadd local sample_river  "`sample_river'"
                                estadd local sample_soil   "`sample_soil'"
                                estadd local control_set   "`control_set'"

                                estimates save $path_data_est/est_beaver_DV`dep_var'_TV`indep_var'_S`sample_cohort'_`sample_river'_`sample_soil'_C`control_set'_FE`fe'_CL`cl'.ster, replace
                            }
                        }
                    }
                }
            }
        }
    }
}
