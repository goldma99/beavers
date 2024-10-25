ggsave_wrapper <- 
#' @description
#' Light wrapper around ggsave to allow for pmap-ing where the input 
#' tribble contains the unexecuted plotting function, to be called only
#' once ggsave is called
#' @returns Called for side effect (writing file)
function(plot_fn, filename, path, width, height, units, ...) {

  file <-
    ggsave(
      plot = plot_fn(),
      filename = filename,
      path = path,
      width = width,
      height = height,
      units = "in",
      dpi = 400
      )
      
  message("Saved: ", file)
}