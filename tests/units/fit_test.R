fit_test <- function(data, values, consistency, i, j) {

  print(values[i,])
  print(consistency[j,])


  # map data
  X <- data$X
  classes <- data$classes

  if( ! consistency$Xcolnames[j] ) {
    colnames(X) <- NULL
  }

  if( ! consistency$Xrownames[j] ) {
    rownames(X) <- NULL
  }


  est <- msgl::fit(
    x = X,
    classes = classes,
    grouping = values$grouping[[i]],
    groupWeights = values$groupWeights[[i]],
    parameterWeights = values$parameterWeights[[i]],
    alpha = values$alpha[i],
    lambda = values$lambda[i],
    d = values$d[i],
    standardize = values$standardize[i],
    intercept = values$intercept[i],
    sparse.data = values$sparseX[i]
  )

  if(nmod(est) != values$d[i]) stop()

  # models
  beta_list <- models(est)
  if(length(beta_list) != values$d[i]) stop()
  if( ! all(sapply(beta_list, function(beta) all(dim(beta) == c(length(unique(classes)), ncol(X) + est$intercept))))) stop()

  # check colnames and rownames of models
  beta <-beta_list[[2]]
  stopifnot(all(rownames(beta) == levels(factor(classes))))
  if( ! is.null(colnames(c)) ) {
    if(est$intercept) {
      stopifnot(all(colnames(beta) == c("Intercept", colnames(x))))
    } else {
      stopifnot(all(colnames(beta) == colnames(x)))
    }
  }

  # Stats
  features_stat(est)
  parameters_stat(est)

  # coef
  if(length(coef(est)) != values$d[i]) stop()

  # print
  print(est)

  res <-  predict(est, X, sparse.data = values$sparseX[j])

  print(res)

  classes <- factor(classes)

  # Check names
  link <- res$link[[2]]
  stopifnot(all(rownames(link) == levels(classes)))
  stopifnot(all(colnames(link) == rownames(x)))

  r <- res$response[[2]]
  stopifnot(all(rownames(r) == levels(classes)))
  stopifnot(all(colnames(r) == rownames(x)))

  cls <- res$classes
  stopifnot(all(as.vector(cls) %in% levels(classes)))
  stopifnot(all(rownames(cls)  == rownames(x)))

  # return beta matrix for args consistency test
  return( beta_list )
}


check_fit_consistency <- function(consistency_list) {

  # consistency beta
  beta_ref <- consistency_list[[1]]

  e <- sapply(consistency_list, function(beta) max(sapply(1:length(beta), function(i)
    mean(abs(beta[[i]]-beta_ref[[i]]))))
  )

  if(max(e) > 1e-2) stop("test failed")
}
