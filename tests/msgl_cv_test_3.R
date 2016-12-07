library(msgl)
library(tools)

### Basic tests
options(warn=2)

data(SimData)



set.seed(100L)

lambda <- msgl::lambda(x, classes, alpha = .5, d = 25L, lambda.min = 0.02, standardize = TRUE)

# This should show a warning
assertWarning(
  msgl::cv(x, classes, alpha = .5, fold = 11L, lambda = lambda, standardize = TRUE)
)
