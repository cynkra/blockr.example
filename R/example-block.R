#' Example Data Block
#'
#' A simple data block that demonstrates essential blockr patterns.
#' This block generates sample data based on user selections.
#'
#' @param dataset Dataset to use: "mtcars", "iris", or "faithful"
#' @param n_rows Number of rows to sample (default: 50)
#' @param add_noise Whether to add random noise to numeric columns
#' @param ... Additional arguments passed to new_data_block
#'
#' @export
new_example_block <- function(
  dataset = "mtcars",
  n_rows = 50L,
  add_noise = FALSE,
  ...
) {
  blockr.core::new_data_block(
    function(id) {
      moduleServer(
        id,
        function(input, output, session) {
          # Initialize reactive values with r_ prefix
          r_dataset <- reactiveVal(dataset)
          r_n_rows <- reactiveVal(n_rows)
          r_add_noise <- reactiveVal(add_noise)

          # Input observers
          observeEvent(input$dataset, {
            r_dataset(input$dataset)
          })

          observeEvent(input$n_rows, {
            r_n_rows(as.integer(input$n_rows))
          })

          observeEvent(input$add_noise, {
            r_add_noise(input$add_noise)
          })

          list(
            expr = reactive({
              # Build expression using parse/glue pattern (modern blockr style)
              dataset_name <- r_dataset()
              n_value <- r_n_rows()
              noise_flag <- r_add_noise()

              if (noise_flag) {
                expr_text <- glue::glue(
                  "blockr.example:::generate_sample_data('{dataset_name}', {n_value}, add_noise = TRUE)"
                )
              } else {
                expr_text <- glue::glue(
                  "blockr.example:::generate_sample_data('{dataset_name}', {n_value}, add_noise = FALSE)"
                )
              }

              parse(text = expr_text)[[1]]
            }),
            state = list(
              dataset = r_dataset,
              n_rows = r_n_rows,
              add_noise = r_add_noise
            )
          )
        }
      )
    },
    function(id) {
      tagList(
        div(
          class = "example-block-container",

          # Simple CSS for clean layout
          tags$style(HTML(
            "
            .example-block-container {
              padding: 15px;
              background: #f8f9fa;
              border-radius: 8px;
              margin-bottom: 15px;
            }
            .example-section {
              margin-bottom: 15px;
            }
            .example-section h4 {
              margin-top: 0;
              margin-bottom: 8px;
              color: #495057;
              font-size: 16px;
            }
            .example-controls {
              display: grid;
              grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
              gap: 10px;
            }
          "
          )),

          # Data Selection Section
          div(
            class = "example-section",
            h4("Data Selection"),
            div(
              class = "example-controls",
              selectInput(
                NS(id, "dataset"),
                label = "Dataset",
                choices = c(
                  "Motor Trend Cars" = "mtcars",
                  "Iris Flowers" = "iris",
                  "Old Faithful Geyser" = "faithful"
                ),
                selected = dataset,
                width = "100%"
              ),
              numericInput(
                NS(id, "n_rows"),
                label = "Sample Size",
                value = n_rows,
                min = 10,
                max = 500,
                step = 10,
                width = "100%"
              ),
              checkboxInput(
                NS(id, "add_noise"),
                label = "Add Random Noise",
                value = add_noise,
                width = "100%"
              )
            )
          ),

          # Help text
          helpText(
            "This example block demonstrates basic blockr patterns:",
            "reactive values, expression building, and state management."
          )
        )
      )
    },
    class = "example_block",
    allow_empty_state = character(0), # No optional fields in this simple example
    ...
  )
}

#' Generate Sample Data (Internal Helper)
#'
#' Internal function to generate sample data based on parameters.
#'
#' @param dataset_name Name of the dataset
#' @param n_rows Number of rows to sample
#' @param add_noise Whether to add noise to numeric columns
#' @keywords internal
generate_sample_data <- function(dataset_name, n_rows, add_noise = FALSE) {
  # Get base data
  base_data <- switch(
    dataset_name,
    "mtcars" = mtcars,
    "iris" = iris,
    "faithful" = faithful,
    mtcars # fallback
  )

  # Sample rows
  n_available <- nrow(base_data)
  n_sample <- min(n_rows, n_available)

  if (n_sample >= n_available) {
    result <- base_data
  } else {
    sample_indices <- sample(n_available, n_sample)
    result <- base_data[sample_indices, , drop = FALSE]
  }

  # Add noise if requested
  if (add_noise) {
    numeric_cols <- sapply(result, is.numeric)
    for (col in names(result)[numeric_cols]) {
      # Add 5% random noise
      noise_factor <- 0.05
      original_values <- result[[col]]
      noise <- rnorm(
        length(original_values),
        mean = 0,
        sd = sd(original_values) * noise_factor
      )
      result[[col]] <- original_values + noise
    }
  }

  # Add metadata as attributes
  attr(result, "source_dataset") <- dataset_name
  attr(result, "sample_size") <- n_sample
  attr(result, "noise_added") <- add_noise

  tibble::as_tibble(result)
}
