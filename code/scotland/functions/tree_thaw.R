tree_thaw <- function(path) {
  
  freeze_file <- file.path(path, "freeze_data_tree.txt")
  
  data_dirs <- read_lines(freeze_file)
  
  data_dir_paths <- map(data_dirs, glue)
  
  walk(data_dir_paths, dir_create)
  
}