library(msgl)

# warnings = errors
options(warn=2)

### Basic tests

data(SimData)
x <- sim.data$x
classes <- sim.data$classes

set.seed(100L)

lambda <- msgl.lambda.seq(x, classes, alpha = .5, d = 25L, lambda.min = 0.02, standardize = FALSE)

fit.cv <- msgl.cv(x, classes, alpha = .5, lambda = lambda, standardize = FALSE)

err.count <- colSums(fit.cv$classes != classes)

if(err.count[1] < 80 | err.count[25] > 30) stop()
stopifnot(all(err.count == Err(fit.cv, type ="count")))

#### without intercept

fit.cv <- msgl.cv(
  x,
  classes,
  alpha = 0.5,
  intercept = FALSE,
  lambda = 0.8,
  standardize = FALSE)

err <- Err(fit.cv, type ="count")
stopifnot(err.count[1] > 80 | err.count[100] < 70)
