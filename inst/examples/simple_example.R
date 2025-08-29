#!/usr/bin/env Rscript

# Simple usage example for blockr.example
# This script demonstrates basic functionality

library(blockr.core)
devtools::load_all() # Load development version

# Basic example
cat("Testing basic example block...\n")
basic_block <- new_example_block()

blockr.core::serve(basic_block, data = list())

# Advanced example with all parameters
cat("Testing advanced example block configuration...\n")
advanced_block <- new_example_block(
  dataset = "iris",
  n_rows = 75,
  add_noise = TRUE
)

blockr.core::serve(advanced_block, data = list())
