source_dir <- function(dir, deprecated_prefix = "ZZZ") {
  
  str_to_ignore <- unclass(glue("^[^{deprecated_prefix}]"))
  regex_to_ignore <- regex(pattern = str_to_ignore)
  
  walk(
    list.files(dir, recursive = TRUE, pattern = regex_to_ignore, full.names = TRUE),
    source
  )
  
  files_in_dir <-
    paste0(" * ", 
           list.files(dir, recursive = TRUE, pattern = regex_to_ignore), 
           collapse = "\n")
  
  message("Sourced `", dir, "`\n", files_in_dir, "\n")
}