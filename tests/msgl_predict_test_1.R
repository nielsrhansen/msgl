library(msgl)

# warnings = errors
options(warn=2)

### Basic tests

data(SimData)


classes <- LETTERS[1:10][classes]

## Lambda sequence

lambda <- msgl::lambda(x, classes, alpha = .5, d = 25L, lambda.min = 0.01, standardize = TRUE)

fit.qwe <- msgl::fit(x, classes, lambda = lambda)

res <- predict(fit.qwe, x)
if(min(colSums(res$classes != classes)) > 0) stop()

res <- predict(fit.qwe, x, sparse.data = TRUE)
if(min(colSums(res$classes != classes)) > 0) stop()

# Test response format
if( ! all(dim(res$link[[1]]) == c(10, 100))) stop()
if( ! all(dim(res$response[[1]]) == c(10, 100))) stop()
if( ! all(dim(res$classes) == c(100, 25))) stop()

# Check if Err gives error if classes are not specified
res <- try(Err(res), silent = TRUE)
if(class(res) != "try-error") stop()
