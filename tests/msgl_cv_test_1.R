library(msgl)
library(tools)

# warnings = errors
options(warn=2)

### Basic tests

data(SimData)


classes <- LETTERS[1:10][classes]

set.seed(100L)

lambda <- msgl::lambda(x, classes, alpha = .5, d = 25, lambda.min = 0.02, standardize = TRUE)

#NOTE test lambda

fit.cv <- msgl::cv(x, classes, alpha = .5, lambda = lambda, standardize = TRUE)

err <- Err(fit.cv, type ="count")

if(err[1] < 80 | err[25] > 30) stop()

#NOTE test features and parameters

# Test response format
if( ! all(dim(fit.cv$link[[1]]) == c(10, 100))) stop()
if( ! all(dim(fit.cv$response[[1]]) == c(10, 100))) stop()
if( ! all(dim(fit.cv$classes) == c(100, 25))) stop()

# some navigation tests
features_stat(fit.cv)
parameters_stat(fit.cv)
best_model(fit.cv)

# Check names
link <- fit.cv$link[[10]]
stopifnot(all(rownames(link) == levels(factor(classes))))
stopifnot(all(colnames(link) == rownames(x)))

res <- fit.cv$response[[10]]
stopifnot(all(rownames(res) == levels(factor(classes))))
stopifnot(all(colnames(res) == rownames(x)))

cls <- fit.cv$classes
stopifnot(all(sort(unique(as.vector(cls))) == levels(factor(classes))))
stopifnot(all(rownames(cls)  == rownames(x)))

# test deprecated warnings

assertWarning(
  lambda <- msgl.lambda.seq(x, classes, alpha = .5, d = 25, lambda.min = 0.02, standardize = TRUE)
)
assertWarning(
  fit.cv <- msgl.cv(x, classes, alpha = .5, lambda = lambda, standardize = TRUE)
)
