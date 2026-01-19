new_example_head_block <- function(n = 6L, ...) {
  new_block(
    ui = function(id) {
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
        reactive_n = reactiveVal(n)
        observeEvent(input$n, reactive_n(input$n))

        # Render outputs
        output$result <- DT::renderDT({
          expr = utils::head(data(), n = reactive_n())
        })

        # Return list w/ expression and state
        list(
          expr = reactive(bquote(
            utils::head(x = .(data), n = .(n), list(n = reactive_n()))
          )),
          state = list(
            n = reactive_n
          )
        )
      })
    },
    class = "example_head_block"
  )
}
