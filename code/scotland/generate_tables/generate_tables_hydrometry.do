/*
   Description: Make tables for river level/flow outcomes ~ beaver
   Author: Miriam Gold
   Reviewer: 
   Last revised: 13 April 2025, mag
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

global path_tab_beaver_hydrometry "$path/output/tables/beaver_hydrometry"

// Regression globals -------------------------------------------
global samples_cohort ///
       g1 ///
       g2 ///
       g3 ///
       g12 ///
       g13 ///
       g23 ///
       g123

global samples_soil ///
       all_soil ///
       AC ///
       IGRG ///
       NAG

global dep_vars ///
	   level_mean ///
       level_max ///
       flow_mean

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
local sample_river river_cells

foreach dep_var in $dep_vars {
	foreach sample_cohort in $samples_cohort {

		est clear
		
		foreach sample_soil in $samples_soil {
			foreach control_set in $control_sets {

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
				est sto `sample_soil'_`control_set_short'

			}
		}

        local filename_panel beaver_hydrometry_DV`dep_var'_SC`sample_cohort'_panel.tex
        local filename_table beaver_hydrometry_DV`dep_var'_SC`sample_cohort'_table.tex

		#delim ;
        estout * using "$path_tab_beaver_hydrometry/`filename_panel'",
            cells(b(star fmt(3)) se(par fmt(3)))
            label 
            style(tex)
            stats(N r2_within ymean est_wc,
                  fmt(%9.0fc 3 3 %9.0fc) 
                  labels("\midrule Observations" "Within \(R^2\)" "Mean Dep. Var." "Weather controls"))
            mgroups("All Soil" "Arable" "Grass/Graze" "Non-Ag",
		            pattern(1 0 1 0 1 0 1 0)
		            span 
		            prefix(\multicolumn{@span}{c}{) 
		            suffix(})
		            erepeat(\cmidrule(lr){@span}))
		    mlabels(none)
            collabels(none)
            varlabels(beaver_d "Beaver Presence")
            drop(`drop_vars')
            starlevels(* 0.10 ** 0.05 *** 0.01)
            prehead(/*\textbf{`panel_title'} \\\midrule*/)
            posthead(& (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\ \midrule)
            prefoot() 
			postfoot(\noalign{\smallskip})
            replace;
        #delim cr
            
		local fe_note "grid cell and time period fixed effects."
        local sample_note "Sample includes only on-river cells."
        local cl_note "grid cell"

        if "`dep_var'" == "level_mean" {
        	local dep_var_title "River level (mean)"
        }
        else if "`dep_var'" == "level_max" {
        	local dep_var_title "River level (max)"
        }
        else if "`dep_var'" == "flow_mean" {
        	local dep_var_title "River flow (mean)"
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

        if "`sample_river'" == "river_cells" {
        	local sample_river_title On-river cells
        }
        else {
        	di as error "Unsupported sample_river value: `sample_river'"
        	exit(198)
        }

        texdoc init "$path_tab_beaver_hydrometry/`filename_table'", replace force

        tex \begin{table}[H]
        tex \captionlistentry[table]{}
        tex \label{table:beaver_hydrometry_DV`dep_var'_SC`sample_cohort'} 
        tex \tiny %\centering             
        tex %Table \ref{table:beaver_hydrometry_DV`dep_var'_SC`sample_cohort'} \\ 
        tex Dep Var: `dep_var_title', Treatment Cohorts: `cohort_title', River sample: `sample_river_title' \\
        tex \begin{threeparttable} 
        tex \begin{tabulary}{\textwidth}{l*{9}{c}@{}} 
        tex \toprule \toprule
        tex \noalign{\smallskip}
        tex \ExpandableInput{\tabPath/beaver_hydrometry/`filename_panel'}
        tex \noalign{\smallskip} 
        tex \midrule \bottomrule 
        tex \end{tabulary}             
        tex \medskip             
        tex %\begin{tablenotes}[flushleft]             
        tex %\setlength\labelsep{0pt}             
        tex %\item             
        tex %\footnotesize 
        tex %\justify 
        tex %%Notes: Estimation results from Equation \eqref{eq:main_beaver_eq}. 
        tex %Each regression includes `fe_note'. 
        tex %Standard errors are clustered at the `cl_note' level.
        tex %`sample_note' \\
        tex %\mbox{*} 0.10 ** 0.05 *** 0.01
        tex %\end{tablenotes}             
        tex \end{threeparttable}                 
        tex \end{table}

        texdoc close

	}
}
