## Source all custom helper functions in a directory ====
source_dir <- function(dir, deprecated_prefix = "ZZZ") {

  str_to_ignore <- glue("^[^{deprecated_prefix}]")
  regex_to_ignore <- regex(pattern = unclass(str_to_ignore))
  
  dir_files <- fs::dir_ls(dir, recurse = TRUE, regexp = regex_to_ignore, type = "file")
  
  walk(dir_files, source)
  
  message("Sourced functions contained in:")
  fs::dir_tree(dir)
}
