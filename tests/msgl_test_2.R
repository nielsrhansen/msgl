library(msgl)

# warnings = errors
options(warn=2)

### Basic tests

data(SimData)
x <- sim.data$x
classes <- sim.data$classes

## Lambda sequence
lambda <- msgl.lambda.seq(x, classes, alpha = 0, d = 25L, lambda.min = 0.05, standardize = FALSE)

## Group lasso

# Dense x
fit1a <- msgl(x, classes, alpha = 0, lambda = lambda, standardize = FALSE)
# (Forced) Sparse x
fit1b <- msgl(x, classes, alpha = 0, lambda = lambda, sparse.data = TRUE, standardize = FALSE)

if(max(abs(fit1a$beta[[25]]-fit1b$beta[[25]])) > 1e-5) stop()

# test that sparse module is used when x is sparse
x <- Matrix(x, sparse = TRUE)
fit1c <- msgl(x, classes, alpha = 0, lambda = lambda, standardize = FALSE)

if( ! fit1c$sparse.data) stop()

# some navigation tests
features_stat(fit1a)
parameters_stat(fit1a)


### Test for errors if X or Y contains NA
xna <- x
xna[1,1] <- NA

res <- try(lambda <- msgl.lambda.seq(xna, classes, alpha = 0, d = 25L, lambda.min = 0.05, standardize = FALSE), silent = TRUE)
if(class(res) != "try-error") stop()

res <- try(fit1a <- msgl(xna, classes, alpha = 0, lambda = lambda, standardize = FALSE), silent = TRUE)
if(class(res) != "try-error") stop()

classesna <- classes
classesna[1] <- NA

res <- try(lambda <- msgl.lambda.seq(x, classesna, alpha = 0, d = 25L, lambda.min = 0.05, standardize = FALSE), silent = TRUE)
if(class(res) != "try-error") stop()

res <- try(fit1a <- msgl(x, classesna, alpha = 0, lambda = lambda, standardize = FALSE), silent = TRUE)
if(class(res) != "try-error") stop()
