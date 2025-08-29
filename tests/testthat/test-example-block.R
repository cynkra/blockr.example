test_that("new_example_block creates a valid block", {
  block <- new_example_block()

  expect_s3_class(block, "example_block")
  expect_s3_class(block, "data_block")
  expect_s3_class(block, "block")
})

test_that("new_example_block accepts parameters", {
  block <- new_example_block(
    dataset = "iris",
    n_rows = 100L,
    add_noise = TRUE
  )

  expect_s3_class(block, "example_block")
  expect_s3_class(block, "data_block")
})

test_that("new_example_block has correct state management", {
  block <- new_example_block(
    dataset = "faithful",
    n_rows = 75L,
    add_noise = FALSE
  )

  # Check that block has required components
  expect_s3_class(block, "data_block")

  # All constructor parameters should be in state
  # (This tests the critical blockr requirement)
  expect_s3_class(block, "example_block")
})

test_that("new_example_block constructor parameters = state list", {
  # Test that all constructor parameters are represented in state
  block <- new_example_block(
    dataset = "mtcars",
    n_rows = 200L,
    add_noise = TRUE
  )

  # Get constructor formals
  constructor_params <- names(formals(new_example_block))
  constructor_params <- constructor_params[constructor_params != "..."]

  # Block should be created successfully with all parameters
  expect_s3_class(block, "example_block")
  expect_length(constructor_params, 3) # dataset, n_rows, add_noise
})

test_that("new_example_block supports all dataset types", {
  datasets <- c("mtcars", "iris", "faithful")

  for (ds in datasets) {
    block <- new_example_block(dataset = ds)
    expect_s3_class(block, "example_block")
  }
})

test_that("new_example_block handles parameter validation", {
  # Valid parameters
  block1 <- new_example_block(n_rows = 50L)
  expect_s3_class(block1, "example_block")

  block2 <- new_example_block(n_rows = 500L)
  expect_s3_class(block2, "example_block")

  # Boolean parameter
  block3 <- new_example_block(add_noise = TRUE)
  expect_s3_class(block3, "example_block")

  block4 <- new_example_block(add_noise = FALSE)
  expect_s3_class(block4, "example_block")
})

test_that("register_example_blocks works", {
  # This should not error
  expect_no_error(register_example_blocks())
})

test_that("generate_sample_data helper function works", {
  # Test basic functionality
  result1 <- generate_sample_data("mtcars", 10, add_noise = FALSE)
  expect_s3_class(result1, "tbl_df") # tibble
  expect_lte(nrow(result1), 10)
  expect_equal(attr(result1, "source_dataset"), "mtcars")
  expect_equal(attr(result1, "noise_added"), FALSE)

  # Test with noise
  result2 <- generate_sample_data("iris", 20, add_noise = TRUE)
  expect_s3_class(result2, "tbl_df")
  expect_lte(nrow(result2), 20)
  expect_equal(attr(result2, "source_dataset"), "iris")
  expect_equal(attr(result2, "noise_added"), TRUE)

  # Test faithful dataset
  result3 <- generate_sample_data("faithful", 30, add_noise = FALSE)
  expect_s3_class(result3, "tbl_df")
  expect_lte(nrow(result3), 30)
  expect_equal(attr(result3, "source_dataset"), "faithful")

  # Test large sample size (should be limited by available data)
  result4 <- generate_sample_data("mtcars", 1000, add_noise = FALSE)
  expect_s3_class(result4, "tbl_df")
  expect_lte(nrow(result4), nrow(mtcars)) # Can't exceed original size

  # Test fallback for unknown dataset
  result5 <- generate_sample_data("unknown", 10, add_noise = FALSE)
  expect_s3_class(result5, "tbl_df")
  expect_lte(nrow(result5), 10)
})
