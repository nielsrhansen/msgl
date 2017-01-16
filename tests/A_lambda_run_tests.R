library(msgl)

source("units/run_tests.R")
source("units/generate_data.R")
source("units/lambda_test.R")

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
    factor(1:ncol(data$X) %% 3)
    ),
  groupWeights = list(NULL),
  parameterWeights = list(NULL),
  alpha = c(0, 0.5, 1),
  d = 100,
  lambda = 0.8,
  intercept = c(TRUE, FALSE),
  standardize  = c(TRUE, FALSE)
)

## consistency args values
consistency <- expand.grid(
  sparseX = c(TRUE, FALSE),
  Xcolnames = c(TRUE, FALSE),
  Xrownames = c(TRUE, FALSE)
)

run_tests(
  data = data,
  args_values = values,
  args_consistency = consistency,
  test = lambda_test,
  check_consistency = check_lambda_consistency
)

data$X <- Matrix(data$X, sparse = TRUE)

run_tests(
  data = data,
  args_values = values,
  args_consistency = consistency,
  test = lambda_test,
  check_consistency = check_lambda_consistency
)
