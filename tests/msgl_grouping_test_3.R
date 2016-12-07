library(msgl)

# warnings = errors
options(warn=2)

### Tests grouping

data(SimData)



### Define grouping
grouping <- 1:400
grouping[1:5] <- 1
grouping[6:10] <- 2 

## Lambda sequence
lambda <- msgl::lambda(x, classes, grouping = grouping, alpha = .5, d = 25L, lambda.min = 0.05, standardize = FALSE)

## Sparse group lasso

# Dense x
fit1a <- msgl::fit(x, classes, grouping = grouping, alpha = .5, lambda = lambda, standardize = FALSE)
# (Forced) Sparse x
fit1b <- msgl::fit(x, classes, grouping = grouping, alpha = .5, lambda = lambda, sparse.data = TRUE, standardize = FALSE)

if( sum(predict(fit1b, x)$classes != predict(fit1a, x)$classes) > 40 ) stop()
