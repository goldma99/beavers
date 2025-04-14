/*
   Description: Make tables for main specifications of is_land_class* ~ beaver
   Author: Miriam Gold
   Reviewer: 
   Last revised: 8 April 2025, mag
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
  local rootDir = "D:/Dropbox/Research"
}
else {
    di as error "D:/Dropbox/Research/beavers directory not found"
}

// File paths -------------------------------------
global path "`rootDir'/beavers"
global path_data "$path/data"
global path_data_treatment "$path_data/data_clean/treatment"
global path_data_est       "$path_data/estimates"

global path_tab_beaver_land_class "$path/output/tables/beaver_land_class"

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
       is_land_class_3

global indep_vars beaver_d

global fes twfe

global control_sets ///
	   no_controls ///
	   weather_controls

********************************************************************************
// 1. Make tables --------------------------------------------------------------
********************************************************************************

local indep_var beaver_d 
local cl river_id
local fe twfe

foreach dep_var in $dep_vars {
	foreach sample_cohort in $samples_cohort {
		foreach sample_soil in $samples_soil {

            est clear

			foreach sample_river in $samples_river {
				foreach control_set in $control_sets {

					if "`sample_river'" == "all_cells" {
					    //local panel_title = "All cells"
					    local sample_river_short ac
					}
					else if "`sample_river'" == "river_cells" {
					    //local panel_title = "River cells"
					    local sample_river_short rc
					}
					else if "`sample_river'" == "non_river_cells" {
					    //local panel_title = "Non-river cells"
					    local sample_river_short nrc
					}
					else {
					    di as error "Unsupported sample_river value: `sample_river'"
					    exit(198)
					}

					if "`control_set'" == "no_controls" {
					    local drop_vars _cons
					    local control_set_short nc
					    local est_wc ""
					}
					else if "`control_set'" == "weather_controls" {
					    local drop_vars _cons tp_mean t2m_mean
					    local control_set_short wc
					    local est_wc "$\checkmark$"
					}

					est use $path_data_est/est_beaver_DV`dep_var'_TV`indep_var'_S`sample_cohort'_`sample_river'_`sample_soil'_C`control_set'_FE`fe'_CL`cl'.ster
					estadd local est_wc "`est_wc'"
					est sto `sample_river_short'_`control_set_short'

				}
			}

            local filename_panel beaver_land_class_DV`dep_var'_SC`sample_cohort'_SS`sample_soil'_panel.tex
            local filename_table beaver_land_class_DV`dep_var'_SC`sample_cohort'_SS`sample_soil'_table.tex

			#delim ;
            estout * using "$path_tab_beaver_land_class/`filename_panel'",
                cells(b(star fmt(3)) se(par fmt(3)))
                label 
                style(tex)
                stats(N r2_within ymean est_wc,
                      fmt(%9.0fc 3 3 %9.0fc) 
                      labels("\midrule Observations" "Within \(R^2\)" "Mean Dep. Var." "Weather controls"))
                mgroups("All Cells" "River Cells" "Non-River Cells",
                pattern(1 0 1 0 1 0)
                span 
                prefix(\multicolumn{@span}{c}{) 
                suffix(})
                erepeat(\cmidrule(lr){@span}))mlabels(none)
                collabels(none)
                varlabels(beaver_d "Beaver Presence")
                drop(`drop_vars')
                starlevels(* 0.10 ** 0.05 *** 0.01)
                prehead(/*\textbf{`panel_title'} \\\midrule*/)
                posthead(& (1) & (2) & (3) & (4) & (5) & (6) \\ \midrule)
                prefoot() 
                postfoot(\noalign{\smallskip})
                replace;
            #delim cr

            
            local fe_note "grid cell and time period fixed effects."
            // local sample_note "Sample includes `cohort_title' in study region."
            local cl_note "grid cell"

            if "`dep_var'" == "is_land_class_1" {
            	local dep_var_title "Share agricultural"
            }
            else if "`dep_var'" == "is_land_class_3" {
            	local dep_var_title "Share Developed"
            }
            else {
            	di as error "Unsupported dep_var value: `dep_var'"
            	exit(198)
            }

            if "`sample_cohort'" == "g1" {
            	local cohort_title "2012"
            }
            else if "`sample_cohort'" == "g2" {
            	local cohort_title "2017"
            }
            else if "`sample_cohort'" == "g3" {
            	local cohort_title "2020"
            }
            else if "`sample_cohort'" == "g12" {
            	local cohort_title "2012, 2017"
            }
            else if "`sample_cohort'" == "g13" {
            	local cohort_title "2012, 2020"
            }
            else if "`sample_cohort'" == "g23" {
            	local cohort_title "2017, 2020"
            }
            else if "`sample_cohort'" == "g123" {
            	local cohort_title "2012, 2017, 2020"
            }
            else {
            	di as error "Unsupported sample_cohort value: `sample_cohort'"
            	exit(198)
            }

            if "`sample_soil'" == "all_soil" {
            	local soil_title "all types"
            }
            else if "`sample_soil'" == "AC" {
            	local soil_title "arable cropping"
            }
            else if "`sample_soil'" == "IGRG" {
            	local soil_title "improved grassland/grazing"
            }
            else if "`sample_soil'" == "NAG" {
            	local soil_title "non-agricultural"
            }
            else {
            	di as error "Unsupported sample_soil value: `sample_soil'" 
            	exit(198)
            }

            texdoc init "$path_tab_beaver_land_class/`filename_table'", replace force

            tex \begin{table}[H]
            tex \captionlistentry[table]{}
            tex \label{table:beaver_land_class_DV`dep_var'_SC`sample_cohort'_SS`sample_soil'} 
            tex \scriptsize %\centering             
            tex %Table \ref{table:beaver_land_class_DV`dep_var'_SC`sample_cohort'_SS`sample_soil'} \\ 
            tex Dep Var: `dep_var_title', Treatment Cohorts: `cohort_title', Soil: `soil_title' \\
            tex \begin{threeparttable} 
            tex \begin{tabulary}{\textwidth}{l*{7}{c}@{}} 
            tex \toprule \toprule
            tex \noalign{\smallskip}
            tex \ExpandableInput{\tabPath/beaver_land_class/`filename_panel'}
            tex \noalign{\smallskip} 
            tex \midrule \bottomrule 
            tex \end{tabulary}             
            tex \medskip             
            tex %\begin{tablenotes}[flushleft]             
            tex %\setlength\labelsep{0pt}             
            tex %\item             
            tex %\footnotesize 
            tex %\justify 
            tex %Notes: Estimation results from Equation \eqref{eq:main_beaver_eq}. 
            tex %Each regression includes `fe_note'. 
            tex %Standard errors are clustered at the `cl_note' level.  \\
            tex %\mbox{*} 0.10 ** 0.05 *** 0.01
            tex %\end{tablenotes}             
            tex \end{threeparttable}                 
            tex \end{table}

            texdoc close

		}
	}
}
