library(msgl)

# warnings = errors
options(warn=2)

### Basic tests

data(SimData)
x <- sim.data$x
classes <- sim.data$classes

set.seed(100L)

lambda <- msgl.lambda.seq(x, classes, alpha = .5, d = 25, lambda.min = 0.02, standardize = TRUE)

#TODO test lambda

fit.cv <- msgl.cv(x, classes, alpha = .5, lambda = lambda, standardize = TRUE)

err <- Err(fit.cv, type ="count")

if(err[1] < 80 | err[25] > 30) stop()

#TODO test features and parameters

# Test response format
if( ! all(dim(fit.cv$link[[1]]) == c(10, 100))) stop()
if( ! all(dim(fit.cv$response[[1]]) == c(10, 100))) stop()
if( ! all(dim(fit.cv$classes) == c(100, 25))) stop()

# some navigation tests
features_stat(fit.cv)
parameters_stat(fit.cv)
best_model(fit.cv)
