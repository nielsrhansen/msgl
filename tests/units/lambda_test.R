lambda_test <- function(data, values, consistency, i, j) {

  # map data
  X <- data$X
  classes <- data$classes

  if( ! consistency$Xcolnames[j] ) {
    colnames(X) <- NULL
  }

  if( ! consistency$Xrownames[j] ) {
    rownames(X) <- NULL
  }


  lambda <- msgl::lambda(
    x = X,
    classes = classes,
    grouping = values$grouping[[i]],
    groupWeights = values$groupWeights[[i]],
    parameterWeights = values$parameterWeights[[i]],
    alpha = values$alpha[i],
    lambda.min = values$lambda[i],
    lambda.min.rel = TRUE,
    d = values$d[i],
    standardize = values$standardize[i],
    intercept = values$intercept[i],
    sparse.data = consistency$sparseX[j]
  )

  return( lambda )
}

check_lambda_consistency <- function(consistency_list) {

  lambda_ref <- consistency_list[[1]]
  e <- sapply(consistency_list, function(lambda) max(abs(lambda-lambda_ref)))

  if(max(e) > 1e-3) stop(paste("test failed with max error = ", max(e)))
}
