plot_balance_by_cohort <- function() {
  
  library(gt)
  
  # Ag-dummy raster, all years
  
  # River grid sf
  #river_grid
  
  # Treatment panel with river cell IDs that match the grid sf
  
  data_balance_fig <-
    river_grid_year_panel_unfilled %>%
    filter(
      (g == 0) | 
        (g == 1 & year <= 2000) | 
        (g == 2 & year < 2017) | 
        (g == 3 & year < 2020)
      ) %>%
    group_by(g) %>% 
    summarise(
      across(
        c(tp_mean, t2m_mean, soil_share_ac, ag_share, on_river),
        list(
          "mean" = ~ mean(.x, na.rm = TRUE), 
          "sd" = ~ sd(.x, na.rm = TRUE)
        ),
        .names = "{.col}.{.fn}"
      )
    ) %>% 
    pivot_longer(
      cols = !g,
      names_to = c("var", "stat"),
      names_sep = "\\."
    ) %>% 
    pivot_wider(
      names_from = stat,
      values_from = value
    ) %>% 
      mutate(
        across(
          c(mean, sd),
          ~ if_else(var %in% c("tp_mean"), .x/1e+03, .x)
        ),
        ymax = mean+sd,
        ymin = mean-sd,
        g = case_match(
          g,
          0 ~ "Never",
          1 ~ "2012",
          2 ~ "2017",
          3 ~ "2020"
        ),
        var = case_match(
          var,
          "ag_share" ~ "Share Ag. Use",
          "on_river" ~ "Cell on river",
          "soil_share_ac" ~ "Share Ag. Soil",
          "t2m_mean" ~ "Temp",
          "tp_mean" ~ "Precip\n(thousands mm)"
        ),
        g = fct_relevel(g, "Never", after = 0),
        var = fct_relevel(var, "Precip\n(thousands mm)", after = Inf)
      )
  
    data_balance_fig %>% 
      ggplot(aes(g, mean)) +
      
      geom_point(
        size = 2.5
      ) +
      geom_errorbar(
        aes(ymax = ymax, ymin = ymin),
        width = 0,
        linewidth = 0.85
        ) +
      
      facet_wrap(~var, scales = "free_x", nrow = 1) +
      
      coord_flip() +
      
      labs(
        y = "Mean +/- Std. Dev.",
        x = "Treatment Cohort"
      ) +
      
      theme_classic() +
      theme(
        strip.background = element_blank(),
        text = element_text(family = "cmss", size = 19),
        axis.title.y = element_text(angle = 90),
        #axis.line = element_blank()
      )
      
    
    
    
    
    river_grid_year_panel_unfilled %>%
      filter(
        (g == 0) | 
          (g == 1 & year <= 2000) | 
          (g == 2 & year < 2017) | 
          (g == 3 & year < 2020)
      ) %>%
      group_by(g)
  #   # pivot_wider(names_from = "stat") %>% 
  #   mutate(
  #     #val_display = scales::label_comma(accuracy = 0.001)(value),
  #     var = case_match(
  #       var,
  #       "ag_share" ~ "Share Ag. Use",
  #       "on_river" ~ "Cell on river",
  #       "soil_share_ac" ~ "Share Ag. Soil",
  #       "t2m_mean" ~ "Temp",
  #       "tp_mean" ~ "Precip"
  #       ),
  #     # cohort = case_match(
  #     #   g,
  #     #   0 ~ "Never",
  #     #   1 ~ "2000-2012",
  #     #   2 ~ "2013-2017",
  #     #   3 ~ "2018-2020"
  #     # )
  #   ) %>%  
  #   pivot_wider(
  #     id_cols = c(var, stat),
  #     names_from = "g",
  #     values_from = "value",
  #     names_prefix = "g"
  #   )
  # 
  # data_balance_table %>% 
  #   gt(
  #     groupname_col = "var",
  #     rowname_col = "stat"
  #   ) %>% 
  #   cols_label(
  #     "stat" = "",
  #     "g0" = "Never",
  #     "g1" = "2012",
  #     "g2" = "2017",
  #     "g3" = "2020"
  #   ) %>% 
  #   tab_spanner(
  #     label  = "Treatment Cohort",
  #     columns = c(g0, g1, g2, g3)
  #   ) 
  
  }