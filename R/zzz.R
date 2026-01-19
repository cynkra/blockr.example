register_example_blocks <- function() {
  register_blocks(
    "new_head_block",
    name = "head block",
    description = "Returns first n rows in data",
    category = "transform",
    icon = "eye",
    package = utils::packageName(),
    overwrite = TRUE
  )
}

.onLoad <- function(libname, pkgname) {
  register_example_blocks()
  invisible(NULL)
}
