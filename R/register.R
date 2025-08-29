#' Register example blocks
#'
#' Register the example data block with the blockr registry
#'
#' @export
register_example_blocks <- function() {
  blockr.core::register_blocks(
    c("new_example_block"),
    name = c("Example Data"),
    description = c(
      "Simple data block demonstrating essential blockr patterns"
    ),
    category = c("data"),
    package = utils::packageName(),
    overwrite = TRUE
  )
}
