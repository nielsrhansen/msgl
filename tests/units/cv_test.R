cv_test <- function(data, values, consistency, i, j) {

  print(values[i,])
  print(consistency[j,])

  set.seed(300)

  # map data
  X <- data$X
  classes <- data$classes

  if( ! consistency$Xcolnames[j] ) {
    colnames(X) <- NULL
  }

  if( ! consistency$Xrownames[j] ) {
    rownames(X) <- NULL
  }

  val <- msgl::cv(
    x = X,
    classes = classes,
    grouping = values$grouping[[i]],
    groupWeights = values$groupWeights[[i]],
    parameterWeights = values$parameterWeights[[i]],
    alpha = values$alpha[i],
    lambda = values$lambda[i],
    d = values$d[i],
    fold = values$fold[i],
    standardize = values$standardize[i],
    intercept = values$intercept[i],
    sparse.data = values$sparseX[i]
  )

  # features and parameters
  features_stat(val)
  parameters_stat(val)

  best_model(val, "sgl")

  classses <- factor(classes)

  # Check names
  link <- val$link[[2]]
  stopifnot(all(rownames(link) == levels(classes)))
  stopifnot(all(colnames(link) == rownames(x)))

  r <- val$response[[2]]
  stopifnot(all(rownames(r) == levels(classes)))
  stopifnot(all(colnames(r) == rownames(x)))

  cls <- val$classes
  stopifnot(all(as.vector(cls) %in% levels(classes)))
  stopifnot(all(rownames(cls)  == rownames(x)))

  # print
  sgl_print(val)

  # Err
  err <- Err(val)

  return( err )
}

check_cv_consistency <- function(consistency_list) {

  # consistency beta
  err_ref <- consistency_list[[1]]

  e <- sapply(consistency_list, function(err) max(abs(err - err_ref)))

  if(max(e) > 1e-3) stop("cv args consistency test failed")
}
