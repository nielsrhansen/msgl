subsampling_test <- function(data, values, consistency, i, j) {

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

  # Skip tests
  if(is.null(rownames(X)) && values$test_train[i] == "C" ) {
    return( NULL )
  }

  if( values$test_train[i] == "A" ) {

    test <- replicate(2, 1:(nrow(X)/2), simplify = FALSE)
    train <- lapply(test, function(s) (1:nrow(X))[-s])

  } else if( values$test_train[i] == "B" ) {

    test <- as.list(1:5) # Test single tests
    train <- replicate(5, 1:nrow(X), simplify = FALSE)

  } else if( values$test_train[i] == "C" ) {

    test <- as.list(rownames(X)[1:5]) # Test single tests
    train <- replicate(5, 1:nrow(X), simplify = FALSE)

  } else {
    stop("unkown test_train")
}

  val <- msgl::subsampling(
    x = X,
    classes = classes,
    grouping = values$grouping[[i]],
    groupWeights = values$groupWeights[[i]],
    parameterWeights = values$parameterWeights[[i]],
    alpha = values$alpha[i],
    lambda = values$lambda[i],
    d = values$d[i],
    training = train,
    test = test,
    standardize = values$standardize[i],
    intercept = values$intercept[i],
    sparse.data = values$sparseX[i]
  )

  # features and parameters
  features_stat(val)
  parameters_stat(val)

  best_model(val)

  classses <- factor(classes)

  # Check names
  link <- val$link[[1]][[2]]

  if(is.numeric(test[[1]])) {
    sample_names <- rownames(x)[test[[1]]]
  } else {
    sample_names <- test[[1]]
  }

  stopifnot(all(rownames(link) == levels(classes)))

  if( ! is.null(rownames(x)) ) {
    stopifnot(all(colnames(link) == sample_names))
  }

  r <- val$response[[1]][[2]]
  stopifnot(all(rownames(r) == levels(classes)))
  if( ! is.null(rownames(x)) ) {
    stopifnot(all(colnames(r) == sample_names))
  }

  cls <- val$classes[[1]]
  stopifnot(all(as.vector(cls) %in% levels(classes)))
  if( ! is.null(rownames(x)) ) {
    stopifnot(all(rownames(cls)  == sample_names))
  }

  # print
  sgl_print(val)

  # Err
  Err(val)

  return( NULL )
}

check_subsampling_consistency <- function(consistency_list) {
  #NOTE implement consistency tests if needed
}
