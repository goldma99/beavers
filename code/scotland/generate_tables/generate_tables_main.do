/*
   Description: Make tables for main specifications of outcome ~ beaver
   Author: Miriam Gold
   Reviewer: 
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
global path_data_treatment "$path_data/data_clean/treatment"
global path_data_est       "$path_data/estimates"
global path_tab_beaver_main "$path/output/tables/beaver_main"

// Regression globals -------------------------------------------
global samples_cohort ///
       overall ///
       g2 ///
       g1

global samples_river ///
       all_cells ///
       river_cells

global samples_soil all_soil

global dep_vars ///
       ag_share ///
       level_mean ///
       level_max ///
       flow_mean

global indep_vars beaver_d

global fes twfe

global control_sets no_controls weather_controls

********************************************************************************
// 1. Make tables --------------------------------------------------------------
********************************************************************************
local sample_soil all_soil

foreach sample_cohort in $samples_cohort {
    foreach control_set in $control_sets {

        if "`control_set'" == "no_controls" {
            local drop_vars _cons
        }
        else if "`control_set'" == "weather_controls" {
            local drop_vars _cons tp_mean t2m_mean
        }

        foreach sample_river in $samples_river {

            if "`sample_river'" == "all_cells" {
                local panel_title = "Panel A: All grid cells"
            }
            else if "`sample_river'" == "river_cells" {
                local panel_title = "Panel B: River grid cells"
            }
            else {
                di as error "Unsupported sample_river value: `sample_river'"
                exit(198)
            }

            ** Read in regressions for one panel (varying dep_vars)
            foreach dep_var in $dep_vars {
                foreach indep_var in $indep_vars {
                    foreach fe in $fes {
                        foreach cl in river_id {                        
                            est use $path_data_est/est_beaver_DV`dep_var'_TV`indep_var'_S`sample_cohort'_`sample_river'_`sample_soil'_C`control_set'_FE`fe'_CL`cl'.ster
                            est sto DV`dep_var'                        
                        }
                    }
                }
            }

            #delim ;
            estout * using "$path_tab_beaver_main/beaver_main_S`sample_cohort'_`sample_river'_panel.tex",
                cells(b(star fmt(3)) se(par fmt(3)))
                label 
                style(tex)
                stats(N r2_within ymean,
                      fmt(%9.0fc 3 3) 
                      labels("\midrule Observations" "Within \(R^2\)" "Mean Dep. Var."))
                mgroups(none)
                mlabels(none)
                collabels(none)
                varlabels(beaver_d "Beaver Presence")
                drop(`drop_vars')
                starlevels(* 0.10 ** 0.05 *** 0.01)
                prehead(\textbf{`panel_title'} \\\midrule)
                posthead(\midrule)
                prefoot() 
                postfoot(\noalign{\smallskip})
                replace;
            #delim cr
        }

        ** Build table container around the two panels created above
        local filename_panel_a "beaver_main_S`sample_cohort'_C`control_set'_all_cells_panel"
        local filename_panel_b "beaver_main_S`sample_cohort'_C`control_set'_river_cells_panel"
        local filename_table "beaver_main_S`sample_cohort'_C`control_set'_table"

        if "`sample_cohort'" == "overall" {
            local cohort_title "all treated cohorts"
        }
        else if "`sample_cohort'" == "g2" {
            local cohort_title "only 2012 and 2017 treated cohorts"
        }
        else if "`sample_cohort'" == "g1" {
            local cohort_title "only 2012 treated cohort"
        }

        local dep_var_row & Share Agri. & River Level (mean) & River Level (max) & River Flow (mean)
        local fe_note "grid cell and time period fixed effects."
        local sample_note "Sample includes `cohort_title' in study region."
        local cl_note "grid cell"
        if "`control_set'" == "no_controls" {
            local control_note "Regression does not include temperature and precipitation covariates"
        }
        else if "`control_set'" == "weather_controls" {
            local control_note "Regression includes average two-meter temperature and average total precipitation covariates"
        }

        texdoc init "$path_tab_beaver_main/`filename_table'.tex", replace force

        tex \begin{table}[htb]
        tex \captionlistentry[table]{}
        tex \label{table:beaver_main_`sample_cohort'_`control_set'} 
        tex \centering             
        tex Table \ref{table:beaver_main_`sample_cohort'_`control_set'} \\ 
        tex Beaver impacts (`cohort_title') \\
        tex \begin{threeparttable} 
        tex \begin{tabulary}{\textwidth}{l*{5}{c}@{}} 
        tex \toprule \toprule
        tex \noalign{\smallskip}
        tex `dep_var_row' \\
        tex & (1) & (2) & (3) & (4) \\
        tex \ExpandableInput{\tabPath/beaver_main/`filename_panel_a'.tex}
        tex \ExpandableInput{\tabPath/beaver_main/`filename_panel_b'.tex}
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
        tex `sample_note'. `control_note'.
        tex Standard errors are clustered at the `cl_note' level.  \\
        tex \mbox{*} 0.10 ** 0.05 *** 0.01
        tex \end{tablenotes}             
        tex \end{threeparttable}                 
        tex \end{table}

        texdoc close
    }
}

********************************************************************************
// 2. Table with only ag-share outcome, with all samples -----------------------
********************************************************************************

est clear
local control_set weather_controls
local sample_soil all_soil 
local cl river_id
local dep_var ag_share
local indep_var beaver_d
local fe twfe

** Read in regressions 
foreach sample_cohort in $samples_cohort {
    foreach sample_river in $samples_river {
        est use $path_data_est/est_beaver_DV`dep_var'_TV`indep_var'_S`sample_cohort'_`sample_river'_`sample_soil'_C`control_set'_FE`fe'_CL`cl'.ster
        est sto C`sample_cohort'_R`sample_river'
    }
}

** Build table
local filename_panel "beaver_main_DVag_share_Sall_samples_panel"
local filename_table "beaver_main_DVag_share_Sall_samples_table"

#delim ;
estout C*_R* using "$path_tab_beaver_main/`filename_panel'.tex",
    cells(b(star fmt(3)) se(par fmt(3)))
    label 
    style(tex)
    stats(N r2_within ymean,
          fmt(%9.0fc 3 3) 
          labels("\midrule Observations" "Within \(R^2\)" "Mean Dep. Var."))
    mgroups("All Treated Cohorts" "2012 and 2017 Cohorts" "2012 Cohort",
            pattern(1 0 1 0 1 0)
            span 
            prefix(\multicolumn{@span}{c}{) 
            suffix(})
            erepeat(\cmidrule(lr){@span}))
    mlabels("All cells" "River cells" "All cells" "River cells" "All cells" "River cells")
    collabels(none)
    varlabels(beaver_d "Beaver Presence")
    drop(_cons tp_mean t2m_mean)
    starlevels(* 0.10 ** 0.05 *** 0.01)
    prehead()
    posthead(   & (1) & (2) & (3) & (4) & (5) & (6)\\ \midrule)
    prefoot() 
    postfoot(\noalign{\smallskip})
    replace;
#delim cr
    
    local fe_note "grid cell and time period fixed effects."
    local sample_note "Samples vary by column."
    local cl_note "grid cell"
    local control_note "Regression includes average two-meter temperature and average total precipitation covariates"

    texdoc init "$path_tab_beaver_main/`filename_table'.tex", replace force

    tex \begin{table}[htb]
    tex \captionlistentry[table]{}
    tex \label{table:beaver_main_ag_share_all_samples} 
    tex \centering             
    tex Table \ref{table:beaver_main_ag_share_all_samples} \\ 
    tex Beaver impacts \\
    tex \begin{threeparttable} 
    tex \begin{tabulary}{\textwidth}{l*{7}{c}@{}} 
    tex \toprule \toprule
    tex \noalign{\smallskip}
    tex \ExpandableInput{\tabPath/beaver_main/`filename_panel'.tex}
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
    tex `sample_note' `control_note'.
    tex Standard errors are clustered at the `cl_note' level.  \\
    tex \mbox{*} 0.10 ** 0.05 *** 0.01
    tex \end{tablenotes}             
    tex \end{threeparttable}                 
    tex \end{table}

    texdoc close

