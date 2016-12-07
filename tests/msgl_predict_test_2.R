library(msgl)

# warnings = errors
options(warn=2)

### Basic tests

data(SimData)


classes <- factor(LETTERS[1:10][classes])

## Lambda sequence

lambda <- msgl::lambda(x, classes, alpha = .5, d = 100L, lambda.min = 0.01, standardize = TRUE)

fit.qwe <- msgl::fit(x, classes, lambda = lambda)

res <- predict(fit.qwe, x)
if(min(colSums(res$classes != classes)) > 0) stop()

res <- predict(fit.qwe, x, sparse.data = TRUE)
if(min(colSums(res$classes != classes)) > 0) stop()

# Check names
link <- res$link[[10]]
stopifnot(all(rownames(link) == levels(factor(classes))))
stopifnot(all(colnames(link) == rownames(x)))

r <- res$response[[10]]
stopifnot(all(rownames(r) == levels(factor(classes))))
stopifnot(all(colnames(r) == rownames(x)))

cls <- res$classes
stopifnot(all(sort(unique(as.vector(cls))) == levels(factor(classes))))
stopifnot(all(rownames(cls)  == rownames(x)))
