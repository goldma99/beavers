# ---------------------------------------------------------------------------- #
#' 
#' Description: Import and clean river network shp from OS Ordnance Survey
#' Author: Miriam Gold
#' Date: 22 Mar 2024
#' Last revised: date, mag
#' Notes: notes
#' 
# ---------------------------------------------------------------------------- #


# Set up ==========================================

## Load packages ====

## File system paths ====

# Read in data ====================================

## Ag parishes in survey region ============
ag_parish_in_survey <-
  path_data_clean_parish %>%
  file.path("ag_parish_in_survey.shp") %>%
  read_sf()

## River ==================================

### River nodes ====
river_node_sf <-
  path_data_scotland_river %>%
  file.path("oprvrs_essh_gb", "data", "HydroNode.shp") %>%
  read_sf()

### River segments =====
river_link_sf <- 
  path_data_scotland_river %>%
  file.path("oprvrs_essh_gb", "data", "WatercourseLink.shp") %>%
  read_sf()

# Clean data ======================================

river_node_sf_clean <-
  river_node_sf %>%
  clean_names() %>%
  # filter to beaver survey region
  st_filter(ag_parish_in_survey) %>%
  # drop z dimension from lat/lon geometry
  st_zm(drop = TRUE, what = "ZM") %>%
  rename(
    id = identifier,
    form = form_of_node
  )

river_link_sf_clean <-
  river_link_sf %>%
  clean_names() %>%
  # filter to beaver survey region
  st_filter(ag_parish_in_survey) %>%
  # drop z dimension from lat/lon geometry
  st_zm(drop = TRUE, what = "ZM") %>%
  # Add row index as column, so that it is accessible when joining beaver points
  rowid_to_column(var = "link_index") %>%
  select(!c(fictitious, name2)) %>%
  rename(
    id = identifier,
    name = name1
  )
  


# Convert river network to graph object ========================================

river_vertices <-
  river_node_sf_clean %>%
  st_drop_geometry()

river_edges <- 
  river_link_sf_clean %>%
  st_drop_geometry() %>%
  select(from = start_node, to = end_node, edge_identifier = identifier) %>%
  filter(
    from %in% river_vertices$identifier,
    to %in% river_vertices$identifier
    )

river_graph <-
  river_edges %>%
  graph_from_data_frame(directed = TRUE, vertices = river_vertices) %>%
  as_tbl_graph()

# river_graph %>%
#   activate(edges) %>%
#   left_join(
#     st_drop_geometry(links_by_first_year),
#     by = c("edge_identifier" = "link_identifier")
#   ) %>%
#   filter(!is.na(first_year)) %>%
#   slice(1:100) %>%
#   ggraph()
#   geom_edge_link()
  

# Analysis ========================================

# Output ==========================================

## Cleaned node and link shapefiles ====

### Nodes ====
path_river_node <- 
  path_data_clean_river %>%
  file.path("scotland_river_nodes", "scotland_river_nodes.shp")

river_node_sf_clean %>%
  write_sf(path_river_node)

### Links ====
path_river_link <-
  path_data_clean_river %>%
  file.path("scotland_river_links", "scotland_river_links.shp")

river_link_sf_clean %>%
  write_sf(path_river_link)

