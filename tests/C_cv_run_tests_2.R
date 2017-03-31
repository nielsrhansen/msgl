library(msgl)

source("units/run_tests.R")
source("units/generate_data.R")
source("units/cv_test.R")

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
  alpha = c(0, 0.5),
  d = 50,
  lambda = 0.95,
  fold = 10,
  intercept = c(FALSE, TRUE),
  standardize = FALSE,
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
  test = cv_test,
  check_consistency = check_cv_consistency
)

data$X <- Matrix(data$X, sparse = TRUE)

not_on_cran(
  run_tests(
    data = data,
    args_values = values,
    args_consistency = consistency,
    test = cv_test,
    check_consistency = check_cv_consistency
  )
)
