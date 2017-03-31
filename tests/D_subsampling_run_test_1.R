library(msgl)

source("units/run_tests.R")
source("units/generate_data.R")
source("units/subsampling_test.R")

# warnings = errors
options(warn=2)
set.seed(100) #  ensures consistency of tests

# Run the tests

## create data
data <- create_test_data()

## Possible args values
values <- expand.grid(
  grouping = list(
    NULL,
    factor(1:ncol(data$X) %% 100)
    ),
  groupWeights = list(NULL),
  parameterWeights = list(NULL),
  alpha = 0.5,
  d = 50,
  lambda = 0.95,
  test_train = c("A", "B", "C"),
  intercept = c(FALSE, TRUE),
  standardize = TRUE,
  sparseX = c(TRUE, FALSE)
)

## consistency args values
consistency <- expand.grid(
  Xcolnames = c(TRUE, FALSE),
  Xrownames = c(TRUE, FALSE)
)

run_tests(
  data = data,
  args_values = values,
  args_consistency = consistency,
  test = subsampling_test,
  check_consistency = check_subsampling_consistency
)

data$X <- Matrix(data$X, sparse = TRUE)

not_on_cran(
  run_tests(
    data = data,
    args_values = values,
    args_consistency = consistency,
    test = subsampling_test,
    check_consistency = check_subsampling_consistency
  )
)
