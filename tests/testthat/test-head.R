# Check constructor
test_that("block constructor returns the correct class", {
  expect_s3_class(new_example_head_block(), "example_head_block")
})

test_that("input widgets work", {
  testServer(
    app = new_example_head_block()$expr_server,
    expr = {
      session$setInputs(n = 2L)
      expect_equal(input$n, 2L)
    }
  )
})

test_that("state returns correctly", {
  testServer(
    app = new_example_head_block()$expr_server,
    expr = {
      # First check default state value
      expect_equal(session$returned$state$n(), 6L)

      # Next, check that updating inputs, updates the state
      session$setInputs(n = 2L)
      expect_equal(session$returned$state$n(), 2L)
    }
  )
})

test_that("expr returns correctly", {
  testServer(
    app = new_example_head_block()$expr_server,
    expr = {
      session$setInputs(n = 2L)
      expression <- eval(session$returned$expr())
      expect_s3_class(expression, "data.frame")
    },
    args = list(data = penguins)
  )
})
