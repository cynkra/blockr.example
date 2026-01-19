pkgload::load_all()
library(blockr)

run_app(
  blocks = c(
    data = new_dataset_block(dataset = "penguins")
  )
)
