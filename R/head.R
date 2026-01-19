#' Head block
#'
#' An example head block to demonstrate the absolute basics of creating your
#' own block.
#'
#' @param n Number of rows
#'
#' @export
new_example_head_block <- function(n = 6L, ...) {
  new_block(
    ui = function(id) {
      # Always return a shiny tagList object
      tagList(
        numericInput(
          inputId = NS(id, "n"),
          label = "Select no. of rows",
          value = n,
          min = 1L
        ),
        DT::DTOutput(NS(id, "result"))
      )
    },
    server = function(id, data) {
      moduleServer(id, function(input, output, session) {
        # Track inputs
        n_rows = reactiveVal(n)
        observeEvent(input$n, n_rows(input$n))

        # Render outputs
        output$result <- DT::renderDT({
          expr = utils::head(data(), n = n_rows())
        })

        # Return list w/ expression and state
        list(
          expr = reactive(bquote(
            utils::head(x = .(data), n = .(n), list(n = n_rows))
          )),
          state = list(
            n = n_rows
          )
        )
      })
    },
    class = "example_head_block"
  )
}
