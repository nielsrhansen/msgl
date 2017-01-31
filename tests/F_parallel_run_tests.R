library(msgl)
library(tools)

# warnings = errors
options(warn=2)

### Basic tests

data(SimData)


###
### Parallel tests
###

x <- Matrix(x, sparse = TRUE)

cl <- makeCluster(2)
registerDoParallel(cl)

fit.sub <- msgl::subsampling(x, classes, alpha = .5, lambda = lambda, training = train, test = test, use_parallel = TRUE)

if(min(Err(fit.sub, type="count")) > 15) stop()

# some navigation tests
features_stat(fit.sub)
parameters_stat(fit.sub)

stopCluster(cl)


# Check names
link <- fit.sub$link
stopifnot(all(rownames(link[[1]]) == levels(factor(classes))))
stopifnot(all(colnames(link[[1]]) == rownames(x)[train[[1]]]))
stopifnot(all(rownames(link[[2]]) == levels(factor(classes))))
stopifnot(all(colnames(link[[2]]) == rownames(x)[train[[2]]]))

res <- fit.sub$response
stopifnot(all(rownames(res[[1]]) == levels(factor(classes))))
stopifnot(all(colnames(res[[1]]) == rownames(x)[train[[1]]]))
stopifnot(all(rownames(res[[2]]) == levels(factor(classes))))
stopifnot(all(colnames(res[[2]]) == rownames(x)[train[[2]]]))

cls <- fit.sub$classes
stopifnot(all(sort(unique(as.vector(cls[[1]]))) %in% levels(factor(classes))))
stopifnot(all(rownames(cls[[1]])  == rownames(x)[test[[1]]]))
stopifnot(all(sort(unique(as.vector(cls[[2]]))) %in% levels(factor(classes))))
stopifnot(all(rownames(cls[[2]])  == rownames(x)[test[[2]]]))

# test deprecated warnings

assertWarning(
  fit.sub <- msgl.subsampling(x, classes, alpha = .5, lambda = lambda, training = train, test = test)
)
