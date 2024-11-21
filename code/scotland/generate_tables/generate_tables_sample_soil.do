/*
   Description: Make tables for outcome ~ beaver, with sample split by soil type
   Author: Miriam Gold
   Reviewer: 
   Last revised: 5 Nov 2024, mag
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
global path_tab_beaver_soil "$path/output/tables/beaver_sample_soil"

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

********************************************************************************
// 2. Table with only ag-share outcome, with all samples -----------------------
********************************************************************************

est clear

foreach sample_cohort in $samples_cohort {

    est clear


    ** Read in regressions 
    foreach sample_soil in $samples_soil {
        foreach sample_river in $samples_river {
            foreach dep_var in ag_share {
                foreach indep_var in $indep_vars {
                    foreach fe in $fes {
                        foreach cl in river_id {

                            if "`sample_soil'" == "all_soil" {
                                local soil_short all
                            }
                            else {
                                local soil_short `sample_soil'
                            }
                            
                            est use $path_data_est/est_beaver_DV`dep_var'_TV`indep_var'_S`sample_cohort'_`sample_river'_`sample_soil'_FE`fe'_CL`cl'.ster
                            est sto C`sample_cohort'_R`sample_river'_S`soil_short'                        
                        
                        }
                    }
                }
            }
        }
    }

    local filename_panel "beaver_sample_soil_DVag_share_S`sample_cohort'_panel"
    local filename_table "beaver_sample_soil_DVag_share_S`sample_cohort'_table"

    #delim ;
    estout * using "$path_tab_beaver_soil/`filename_panel'.tex",
        cells(b(star fmt(3)) se(par fmt(3)))
        label 
        style(tex)
        stats(N r2_within ymean,
              fmt(%9.0fc 3 3) 
              labels("\midrule Observations" "Within \(R^2\)" "Mean Dep. Var."))
        mgroups("All Soil Types" "Arable" "Grassland" "Non Agri",
            pattern(1 0 1 0 1 0 1 0)
            span 
            prefix(\multicolumn{@span}{c}{) 
            suffix(})
            erepeat(\cmidrule(lr){@span}))
        mlabels("All cells" "River cells" "All cells" "River cells" "All cells" "River cells" "All cells" "River cells")
        collabels(none)
        varlabels(beaver_d "Beaver Presence")
        drop(_cons)
        starlevels(* 0.10 ** 0.05 *** 0.01)
        prehead()
        posthead(& (1) & (2) & (3) & (4) & (5) & (6) & (5) & (6) & (7) & (8)\\ \midrule)
        prefoot() 
        postfoot(\noalign{\smallskip})
        replace;
    #delim cr
        
    local fe_note "grid cell and time period fixed effects."
    local sample_note "Samples vary by column."
    local cl_note "grid cell"

    texdoc init "$path_tab_beaver_soil/`filename_table'.tex", replace force

    tex \begin{table}[htb]
    tex \captionlistentry[table]{}
    tex \label{table:beaver_sample_soil_S`sample_cohort'} 
    tex \centering             
    tex Table \ref{table:beaver_sample_soil_S`sample_cohort'} \\ 
    tex Beaver impacts \\
    tex \begin{threeparttable} 
    tex \begin{tabulary}{\textwidth}{l*{9}{c}@{}} 
    tex \toprule \toprule
    tex \noalign{\smallskip}
    tex \ExpandableInput{\tabPath/beaver_sample_soil/`filename_panel'.tex}
    tex \noalign{\smallskip} 
    tex \midrule \bottomrule 
    tex \end{tabulary}             
    tex \medskip             
    tex \begin{tablenotes}[flushleft]             
    tex \setlength\labelsep{0pt}             
    tex \item             
    tex \footnotesize 
    tex \justify 
    tex Notes: Estimation results from Equation \eqref{eq:main_beaver_eq}. 
    tex Each regression includes `fe_note' 
    tex `sample_note' 
    tex Standard errors are clustered at the `cl_note' level.  \\
    tex \mbox{*} 0.10 ** 0.05 *** 0.01
    tex \end{tablenotes}             
    tex \end{threeparttable}                 
    tex \end{table}

    texdoc close

}

