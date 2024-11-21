/*
   Description: Plot distribution of jackknife resampled coefficients
   Author: Miriam Gold
   Reviewer: name
   Last revised: 18 Nov 2024, mag
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

global path_data_treatment     "$path_data/data_clean/treatment"
global path_data_est           "$path_data/estimates"
global path_data_est_jackknife "$path_data_est/jackknife"

global path_fig "$path/output/figures"

********************************************************************************
// 1. Read in jackknifed coefficients ------------------------------------------
********************************************************************************


// Regression globals -------------------------------------------
global samples_cohort ///
       overall

global samples_river ///
       river_cells

global samples_soil ///
       AC

global dep_vars ///
       ag_share

global indep_vars beaver_d

global fes twfe

********************************************************************************
// 1. Read in data -------------------------------------------------------------
********************************************************************************

foreach sample_cohort in $samples_cohort {
    foreach sample_river in $samples_river {
        foreach sample_soil in $samples_soil {
            foreach dep_var in $dep_vars {
                foreach indep_var in $indep_vars {
                    foreach fe in $fes {
                        foreach cl in river_id {

                            cd $path_data_est_jackknife

                            gen omitted_cell = ""
                            gen beta_beaver = .

                            qui fs est_beaver_DV`dep_var'_TV`indep_var'_S`sample_cohort'_`sample_river'_`sample_soil'_FE`fe'_CL`cl'_jk*.ster

                            foreach est_file in `r(files)' {
                                insobs 1
                                est use `est_file'
                                local beta_beaver = e(b)[1, "beaver_d"]
                                local omitted_cell = e(omitted_cell)

                                replace omitted_cell = "`omitted_cell'" if _n == _N
                                replace beta_beaver = `beta_beaver' if _n == _N
                            }
                        }
                    }
                }
            }
        }
    }
}        


********************************************************************************
// 2. Plot jackknife beta distribution -----------------------------------------
********************************************************************************

est use $path_data_est/est_beaver_DVag_share_TVbeaver_d_Soverall_river_cells_AC_FEtwfe_CLriver_id.ster
local beta_main = e(b)[1, "beaver_d"]

#delim ;
twoway 
    (hist beta_beaver, 
        color("96 125 139%80")    
        lcolor(none))
    (scatteri 0 `beta_main' 5000 `beta_main', c(l) m(i) lcolor("245 127 23") lwidth(medthick)),
    plotregion(color(white))
    xtitle("Effect of beaver entry on agriculture share") 
    ytitle("")
    ylab(, angle(0))
    ysc(noextend)
    xsc(noextend)
    subtitle("Density", position(11) size(medium))
    legend(off);
#delim cr

local file_name = "$path_fig/jackknife_distribution_Soverall_river_cells_AC"
graph export "`file_name'.svg", replace 
shell inkscape --export-type="pdf" "`file_name'.svg"    
