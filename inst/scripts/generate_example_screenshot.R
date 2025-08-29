#!/usr/bin/env Rscript

#' Generate Screenshot for blockr.example README
#'
#' This script generates a screenshot using the proven blockr approach
#' Uses webshot2::appshot() for reliable screenshot generation

# Check dependencies
if (!requireNamespace("webshot2", quietly = TRUE)) {
  stop("Please install webshot2: install.packages('webshot2')")
}

if (!requireNamespace("blockr.example", quietly = TRUE)) {
  message("Loading blockr.example from current directory...")
}

if (!requireNamespace("blockr.core", quietly = TRUE)) {
  stop("blockr.core package must be installed")
}

library(webshot2)
library(blockr.core)

# Load current development version
devtools::load_all()

# Increase timeout for Shiny app launching
options(webshot.app.timeout = 120)

# Configuration
SCREENSHOT_WIDTH <- 1200
SCREENSHOT_HEIGHT <- 800
OUTPUT_DIR <- "man/figures"

# Create output directory if it doesn't exist
if (!dir.exists(OUTPUT_DIR)) {
  dir.create(OUTPUT_DIR, recursive = TRUE)
}

cat("Generating screenshot for blockr.example...\n")

# Helper function to create temporary app and take screenshot
create_example_screenshot <- function(block, filename, data = list()) {
  cat(sprintf("Generating %s...\n", filename))

  tryCatch(
    {
      # Create temporary directory for the app
      temp_dir <- tempfile("blockr_example_app")
      dir.create(temp_dir)

      # Save data to RDS file (empty list for example block)
      saveRDS(data, file.path(temp_dir, "data.rds"))

      # Create minimal app.R file
      app_content <- sprintf(
        '
# Load the current development version
devtools::load_all("/Users/christophsax/git/blockr/blockr.example")
library(blockr.core)

# Load data
data <- readRDS("data.rds")

# Run the app - Simple example block
blockr.core::serve(
  %s,
  data = data
)
    ',
        deparse(substitute(block), width.cutoff = 500)
      )

      writeLines(app_content, file.path(temp_dir, "app.R"))

      # Take screenshot using appshot (same as blockr.ggplot)
      webshot2::appshot(
        app = temp_dir,
        file = file.path(OUTPUT_DIR, filename),
        vwidth = SCREENSHOT_WIDTH,
        vheight = SCREENSHOT_HEIGHT,
        delay = 6 # Wait for example block to load
      )

      # Cleanup
      unlink(temp_dir, recursive = TRUE)

      cat(sprintf("✓ %s created\n", filename))
    },
    error = function(e) {
      cat(sprintf("✗ Failed to create %s: %s\n", filename, e$message))
    }
  )
}

# Generate the README example screenshot
create_example_screenshot(
  new_example_block(dataset = "mtcars", n_rows = 100, add_noise = TRUE),
  "example-block.png"
)

# Generate additional screenshots for different configurations
create_example_screenshot(
  new_example_block(dataset = "iris", n_rows = 75, add_noise = FALSE),
  "example-block-iris.png"
)

cat("Screenshot generation complete!\n")
cat(sprintf("Screenshots saved to: %s/\n", OUTPUT_DIR))
cat("\nTo verify screenshots show working functionality:\n")
cat("- Should show UI controls (dataset, n_rows, add_noise)\n")
cat("- Should show data table with sampled rows\n")
cat("- UI + data = working block ✓\n")
cat("- Only UI = broken block ✗\n")
