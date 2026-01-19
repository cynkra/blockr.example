pkgload::load_all()
library(blockr)

run_app(
  blocks = c(
    data = new_dataset_block(dataset = "penguins"),
    head = new_example_head_block()
  ),
  links = list(from = "data", to = "head")
)
