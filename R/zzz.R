register_example_blocks <- function() {
  register_blocks()
}

.onLoad <- function(libname, pkgname) {
  register_example_blocks()
  invisible(NULL)
}
