#' @keywords internal
#' @noRd
new_example_block <- function(server, ui, class, ctor = sys.parent(), ...) {
  new_block(server, ui, c(class, "example_block"), ctor, ...)
}

#' @export
block_output.example_block <- function(x, result, session) {
  DT::renderDT(result)
}

#' @export
block_ui.example_block <- function(id, x, ...) {
  tagList(
    DT::DTOutput(NS(id, "result"))
  )
}
