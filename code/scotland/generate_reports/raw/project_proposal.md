---
title: Estimating the Impact of Beaver Activity on Agriculture
author: Miriam Gold\footnote{goldm@uchicago.edu}, The University of Chicago\footnote{5801 S Ellis Ave, Chicago, IL 60637}
date: 22 April 2024
geometry:
    - top=1.5in
    - bottom=1.5in
    - left=1.5in
    - right=1.5in
fontfamily: libertinus
fontfamilyoptions:
    - osf
    - p
numbersections: True
header-includes: |
    ```{=latex}
    
    %\usepackage{lmodern}
    %\usepackage[T1]{fontenc}

    \usepackage{csquotes}

    \newcommand{\sectionsc}[2][0.2]{\fontfamily{cmr}\textsc{\textbf{#2}} \hspace{#1em}}
    ```
---

\fontsize{12}{20}
\selectfont

# Summary

Given the alarming rate of climate change, habitat destruction, and biodiversity loss, there is an increasing focus on wildlife reintroductions. While these efforts bring many benefits, their costs, and how to mitigate them, are less well understood. A salient example are the long-standing conflicts between beavers and agricultural operators. While beavers, as ecosystem engineers, produce a range of well-documented ecological benefits, many farmers fear that beaver dam construction or burrowing in floodbanks could cause costly flooding, or that beavers will graze on their crops and fell valuable timber resources. The recent unplanned emergence of beavers in an agriculturally productive region of Scotland presents a case study to empirically test the impact of beaver activity on agriculture, particularly in light of severe claims of potential damages alleged by farmers groups in the country. To this end, I wish to acquire data on beaver movement and expansion over the past decade or so. The three surveys administered by NatureScot would offer an invaluable resource to the project. As discussed below, accessing the full set of survey variables would enable a far greater degree of precision in my analysis.   

# Motivation 

In the face of climate change, habitat destruction, and biodiversity loss, many policymakers and conservationists advocate wildlife reintroductions. Though often beneficial to ecological functioning, tourism revenues, and species preservation, reintroduced wildlife, living close to human society, can produce a range of unexpected externalities. These include spreading disease, preying on livestock or crops, colliding with cars, and acting as ecologically-destructive invasive species. 

One salient example of a highly contested reintroduction is that the beaver and its effects on agriculture functioning. An ecosystem engineer that alters the course of rivers, impounds wetlands behind its dams, fells timber, and grazes on vegetation, the beaver brings a plethora of well-documented beneficial services. But conflict, particularly with agriculture operators, has frequently arisen throughout the history of beaver-human interactions. Indeed, much of the landscape alterations undertaken to establish productive agriculture (e.g., clearing woodlands and draining swamps) drove beavers into marginal habitats.

A recent unplanned, unauthorized emergence of a large beaver population in Scotland, where wild beavers had not appeared since their anthropogenic extinction centuries earlier, presents a valuable natural experiment to estimate the general impact of beaver activity on agricultural viability. In the wake of the beaver repopulation, there has been a significant outcry among farmers groups, alleging massive, business-crippling costs.

# Data 

To measure agricultural response to beaver activity, I plan to use data from the Scottish Government Agricultural Statistics annual June Agricultural Census. In order to capture a causal effect of beaver presence on agriculture, I need data on beaver movement over time. The three Tayside surveys administered by NatureScot, in 2012, 2017-18, and 2020-21, are crucial to this end. Based on my reading of the literature, I aim to measure the density of beavers around agricultural installations, not merely whether there are _any_ beavers. In other words, I want to be able to discern not only between cases where there were 0 vs. >0 beavers, but also between cases where there was 3 beavers vs. 10 beavers. To do so, I would greatly benefit from access to the full set of variables collected by the survey team, including but not limited to the following:

- Activity type (Sign)
- Ordnance Survey (OS) grid reference
- Photo No. (if appropriate)
- Estimated age (fresh, old or mixed)
- Dam dimensions
- River or waterbody name
- Land use (dominant along water course and surrounding area i.e., within 100m radius)
- Beaver activity effort (low, medium or high)
- Management impact (NA, low, medium or high)
- Any other comments
- Recorder initials\footnote{This variable is less important to my use case, and so if sharing it presents additional privacy concerns, I am more than happy to forgo its acquisition.}