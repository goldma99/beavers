tree_freeze <- function(path, pattern) {
  
  glob <- glue("*{pattern}/*")
  
  data_dirs <- 
    path %>% 
    dir_ls(recurse = TRUE, type = "dir", glob = glob) %>% 
    str_replace(path, "{path}")
  
  if (!length(data_dirs)) stop("No directories found")
  
  out_path <- file.path(path, glue("freeze_{pattern}_tree.txt"))
  
  write_lines(data_dirs, out_path)
  
  message("Saved: ", out_path)
  dir_tree(path, type = "dir",regexp = glob)
  
}

