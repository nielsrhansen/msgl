library(msgl)

# warnings = errors
options(warn=2)

### Basic tests

data(SimData)

set.seed(100L)

lambda <- msgl::lambda(x, classes, alpha = .5, d = 25L, lambda.min = 0.02, standardize = FALSE)

fit.cv <- msgl::cv(x, classes, alpha = .5, lambda = lambda, standardize = FALSE)

err.count <- colSums(fit.cv$classes != classes)

if(err.count[1] < 80 | err.count[25] > 30) stop()
stopifnot(all(err.count == Err(fit.cv, type ="count")))

#### without intercept

fit.cv <- msgl::cv(
  x,
  classes,
  alpha = 0.5,
  intercept = FALSE,
  lambda = 0.8,
  standardize = FALSE)

err <- Err(fit.cv, type ="count")
stopifnot(err.count[1] > 80 | err.count[100] < 70)

#### Subsampling
lambda <- msgl::lambda(x, classes, alpha = .5, d = 25L, lambda.min = 0.05, standardize = TRUE)

test <- list(1:20, 21:40)
train <- lapply(test, function(s) (1:length(classes))[-s])

fit.sub <- msgl::subsampling(x, classes, alpha = .5, lambda = lambda, training = train, test = test)
if(min(Err(fit.sub, type="count")) > 15) stop()
