library(msgl)
library(tools)

data(SimData)
set.seed(200)

### Test for errors if standardize fails
xz <- x
xz[,100] <- 0

assertError(
  msgl::fit(xz, classes, alpha = 0.5, lambda = 0.8, standardize = TRUE)
)

### Test for errors if X or Y contains NA
xna <- x
xna[1,1] <- NA

res <- try(lambda <- msgl::lambda(xna, classes, alpha = 0, d = 25L, lambda.min = 0.05, standardize = FALSE), silent = TRUE)
if(class(res) != "try-error") stop()

res <- try(fit1a <- msgl::fit(xna, classes, alpha = 0, lambda = 0.8, standardize = FALSE), silent = TRUE)
if(class(res) != "try-error") stop()

classesna <- classes
classesna[1] <- NA

res <- try(lambda <- msgl::lambda(x, classesna, alpha = 0, d = 25L, lambda.min = 0.05, standardize = FALSE), silent = TRUE)
if(class(res) != "try-error") stop()

res <- try(fit1a <- msgl::fit(x, classesna, alpha = 0, lambda = 0.8, standardize = FALSE), silent = TRUE)
if(class(res) != "try-error") stop()

# test deprecated warnings

assertWarning(
  fit1c <- msgl(x, classes, alpha = 0, lambda = 0.8, standardize = FALSE)
)

assertWarning(
  lambda <- msgl.lambda.seq(x, classes, alpha = .5, d = 25, lambda.min = 0.02, standardize = TRUE)
)
assertWarning(
  fit.cv <- msgl.cv(x, classes, alpha = .5, lambda = 0.8, standardize = TRUE)
)
