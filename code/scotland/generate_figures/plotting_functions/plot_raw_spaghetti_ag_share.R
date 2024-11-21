plot_raw_spaghetti_ag_share_g2017 <- function() {
  
  g2017_ac_river <-
    river_grid_year_panel_unfilled[
      g %in% c(0, 2) & on_river == 1 & lccd_mj_dom == "AC" & !is.na(ag_share)
    ][,
      g_title := ifelse(g == 0, "Never Treated", "Treated in 2017")
    ]
  
  g2017_ac_river %>%
    #filter(river_id == 10) %>%
    group_by(river_id) %>%
    mutate(
      ag_share_2017 = ag_share[year == 2017],
      ag_share_rel_2017 = ag_share - ag_share_2017
    ) %>%
    ungroup() %>%

    ggplot(aes(year, ag_share_rel_2017, group = river_id)) +
    
    geom_line(alpha = 0.2, color = "#90A4AE", linewidth = 1) +
    geom_hline(yintercept = 0, color = "black", linewidth = 1) +
    geom_vline(xintercept = 2017, color = "#F57F17", lty = 2, linewidth = 1) +
    
    facet_wrap(~g_title, nrow = 2) +
    
    scale_x_continuous(
      breaks = c(1990, 2000, 2007, 2015, 2017, 2018, 2019, 2020, 2021, 2022)
    ) +
    
    labs(
      subtitle = "Share Agri. (relative to 2017)",
      x = NULL,
      y = NULL
    ) +
    
    theme_minimal() +
    theme(
      text = element_text(family = "cmr", size = 19),
      axis.text.x = element_text(angle = 45, hjust = 1),
      panel.grid.minor.x = element_blank()
    )
}