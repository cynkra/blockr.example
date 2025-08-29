# Claude Development Notes for blockr.example

## Commit Policy
- NEVER include Claude attribution in commit messages
- NEVER add "Co-Authored-By: Claude" lines
- Use standard commit messages without AI mentions

## Package Overview

blockr.example provides a minimal template for creating blockr packages. It demonstrates essential blockr patterns with a simple data block that generates sample data from built-in R datasets.

## Known False Positives in R CMD Check

### DESCRIPTION Author/Maintainer Fields
**ERROR**: DESCRIPTION file is missing required fields (Author/Maintainer). The Authors@R field is correctly specified but R CMD check needs the generated Author and Maintainer fields. This happens when the package hasn't been built yet.

**Status**: IGNORE - This is a false positive. The Authors@R field is correctly specified and will generate the necessary fields when the package is built with `devtools::document()`.

## Current State Analysis

### What's Working
- Simple data block with 3 parameters (dataset, n_rows, add_noise)
- Basic block structure and registration
- Clean UI with dataset selection and sample size controls
- Screenshot validation infrastructure
- Essential blockr patterns demonstrated

### Template Design Principles

#### 1. **Minimal Complexity**
- Only 3 user parameters vs 13+ in complex packages
- Uses built-in datasets (mtcars, iris, faithful) - no external dependencies
- Simple UI layout with clean styling
- ~150 lines total vs 700+ in complex blocks

#### 2. **Essential blockr Patterns**
All critical patterns are demonstrated:
- Reactive values with `r_` prefix
- Modern expression building with `parse(text = glue::glue())`
- Complete state management (all constructor params in state)
- Proper input observers
- Clean UI structure with sections

#### 3. **Teaching Tool**
- Clear parameter examples (dataset selection, numeric input, checkbox)
- Internal helper function showing data processing patterns
- Comments explaining blockr concepts
- No complex dependencies to distract from core patterns

## Template Usage Instructions

### For New blockr Package Development

This package serves as the starting template for new blockr packages:

1. **Fork/Copy Structure**: Copy this package as starting point
2. **Rename Package**: Update DESCRIPTION, function names, file names
3. **Replace Block Logic**: Modify `new_example_block()` for your use case
4. **Update Dependencies**: Add required packages to DESCRIPTION Imports
5. **Screenshot Validation**: Use existing infrastructure to verify blocks work
6. **Extend as Needed**: Add more blocks, helpers, tests

### Key Template Files

- **R/example-block.R**: Main block implementation showing all essential patterns
- **R/register.R**: Block registration with blockr.core
- **R/zzz.R**: Package loading and registration
- **inst/scripts/**: Screenshot validation infrastructure
- **CLAUDE.md**: Development documentation (this file)

## Implementation Patterns

### Critical Patterns to Follow

1. **Reactive Values**: Always use `r_` prefix (e.g., `r_dataset`, `r_n_rows`)
2. **Expression Building**: Use `parse(text = glue::glue())` pattern, NEVER bquote
3. **State Management**: Include ALL constructor parameters in state list
4. **Internal Helpers**: Use `:::` for internal functions (see `generate_sample_data`)
5. **Clean UI**: Simple grid layout with sections and proper styling

### Example Block Template Structure

```r
new_example_block <- function(
  dataset = "mtcars",      # String parameter with choices
  n_rows = 50L,           # Numeric parameter with validation
  add_noise = FALSE,      # Boolean parameter
  ...
) {
  blockr.core::new_data_block(
    function(id) {
      moduleServer(id, function(input, output, session) {
        # 1. Initialize reactive values
        r_dataset <- reactiveVal(dataset)
        r_n_rows <- reactiveVal(n_rows)
        r_add_noise <- reactiveVal(add_noise)

        # 2. Input observers
        observeEvent(input$dataset, { r_dataset(input$dataset) })
        observeEvent(input$n_rows, { r_n_rows(as.integer(input$n_rows)) })
        observeEvent(input$add_noise, { r_add_noise(input$add_noise) })

        list(
          # 3. Expression building (parse/glue pattern)
          expr = reactive({
            expr_text <- glue::glue("package:::function('{r_dataset()}', {r_n_rows()})")
            parse(text = expr_text)[[1]]
          }),
          # 4. State management (ALL constructor params)
          state = list(
            dataset = r_dataset,
            n_rows = r_n_rows, 
            add_noise = r_add_noise
          )
        )
      })
    },
    function(id) {
      # 5. UI function with clean layout
      tagList(/* UI elements */)
    },
    class = "example_block",
    ...
  )
}
```

## Testing Strategy

### Screenshot Validation Method
The Screenshot Validation Method is the PRIMARY debugging tool for blockr packages:

1. Generate screenshots of blocks in action
2. Visual validation:
   - ✅ Working = Screenshot shows UI + rendered data/output
   - ❌ Broken = Screenshot shows only UI, no data/output
3. Use for regression testing after each change

**Key Script**: `inst/scripts/generate_example_screenshot.R`

### Unit Tests
- Constructor tests with various parameters
- Reactive value initialization tests  
- Expression generation tests
- State management consistency tests

## Development Workflow

1. **Start with Template** - Use this blockr.example as foundation
2. **Modify Block Logic** - Replace example data generation with your functionality  
3. **Update UI Components** - Customize input controls for your parameters
4. **Test with Screenshots** - Verify blocks work (show UI + output)
5. **Add Unit Tests** - Ensure parameter and state consistency
6. **Document Changes** - Update README with your specific functionality

## CRITICAL RULE: Constructor Parameters = State List

**ALL constructor parameters MUST be in the state list!** This is a fundamental blockr requirement.

```r
new_example_block <- function(
  param1 = default1,
  param2 = default2,
  param3 = default3,
  # ... ALL parameters
) {
  # ...
  state = list(
    param1 = r_param1,
    param2 = r_param2, 
    param3 = r_param3,
    # ... MUST include ALL constructor parameters
  )
}
```

## Key Patterns to Follow (from blockr ecosystem)

### Reactive Value Pattern
```r
# Initialize
r_field <- reactiveVal(field)

# Observer
observeEvent(input$field, {
  r_field(input$field)
})

# In state list
state = list(field = r_field)

# In expression
field_val <- r_field()
```

### Expression Building Pattern - CRITICAL
**ALWAYS use `parse(text = glue::glue())` pattern, NEVER bquote():**

```r
# CORRECT pattern (blockr ecosystem standard):
expr = reactive({
  text <- glue::glue("function_name(param = '{r_param()}')")
  parse(text = text)[[1]]
})

# WRONG pattern (DO NOT USE):
expr = reactive({
  bquote(function_name(param = .(r_param())))
})
```

### State Management Pattern
ALL reactive values MUST be in the state list matching constructor parameters exactly.

## Known Working Patterns

From blockr ecosystem success:
- Screenshot validation catches issues immediately
- `allow_empty_state` can be empty for required-parameter blocks
- parse/glue pattern is cleaner and more debuggable than bquote
- Proper reactive value management prevents mysterious failures
- Built-in datasets avoid external dependency complications

## Development Commands

### Test package
```bash
R CMD check --no-manual --no-build-vignettes .
```

### Generate screenshot validation
```r
# Execute screenshot validation
source("inst/scripts/generate_example_screenshot.R")

# Verify screenshots show working blocks (UI + output)
# Check man/figures/ directory for generated screenshots
list.files("man/figures/", pattern = "\\.png$")

# If screenshots only show UI (no data), debug:
# 1. Check parse/glue expression syntax
# 2. Verify state management (all constructor params in state)
# 3. Check internal helper functions
```

### Load for development
```r
devtools::load_all()
```

## Template Customization Guide

### To Create a New blockr Package from this Template

1. **Copy Package Structure**
```bash
cp -r blockr.example my_new_blockr_package
cd my_new_blockr_package
```

2. **Rename Package**
- Update `DESCRIPTION`: Package name, title, description
- Rename R files: `example-block.R` → `my-block.R`
- Update function names: `new_example_block` → `new_my_block`

3. **Customize Block Logic**
- Replace `generate_sample_data()` with your data logic
- Update constructor parameters for your use case
- Modify UI inputs for your specific parameters
- Update expression building to call your functions

4. **Update Registration**
- `R/register.R`: Update function names and descriptions
- `R/zzz.R`: Update registration call

5. **Test and Validate**
- Update screenshot generation script for your block
- Run screenshot validation to verify functionality
- Update README with your specific examples

## Success Metrics

A successful blockr.example template provides:
- ✅ Working screenshot showing UI + data output
- ✅ All essential blockr patterns demonstrated
- ✅ Minimal complexity (3 parameters, built-in data)
- ✅ Clear customization path for new packages
- ✅ Complete development infrastructure (tests, screenshots, docs)
- ✅ Professional documentation and examples

This template serves as the foundation for the blockr-setup-package agent and direct manual package creation.