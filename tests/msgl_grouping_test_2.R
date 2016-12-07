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
lambda <- msgl::lambda(x, classes, grouping = grouping, alpha = 0, d = 25L, lambda.min = 0.05, standardize = FALSE)

# Dense x
fit1a <- msgl::fit(x, classes, grouping = grouping, alpha = 0, lambda = lambda, standardize = FALSE)

# (Forced) Sparse x
fit1b <- msgl::fit(x, classes, grouping = grouping, alpha = 0, lambda = lambda, sparse.data = TRUE, standardize = FALSE)

if( sum(predict(fit1b, x)$classes[,c(5,10, 15, 20, 25)] != predict(fit1a, x)$classes[,c(5,10, 15, 20, 25)]) > 10 ) stop()
