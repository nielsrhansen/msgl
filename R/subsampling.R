#' @title Multinomial sparse group lasso generic subsampling procedure
#'
#' @description
#' Multinomial sparse group lasso generic subsampling procedure using multiple possessors
#'
#' @param x design matrix, matrix of size \eqn{N \times p}.
#' @param classes classes, factor of length \eqn{N}.
#' @param sampleWeights sample weights, a vector of length \eqn{N}.
#' @param grouping grouping of features (covariates), a vector of length \eqn{p}. Each element of the vector specifying the group of the feature.
#' @param groupWeights the group weights, a vector of length \eqn{m} (the number of groups).
#' If \code{groupWeights = NULL} default weights will be used.
#' Default weights are 0 for the intercept and
#' \deqn{\sqrt{K\cdot\textrm{number of features in the group}}}
#' for all other weights.
#' @param parameterWeights a matrix of size \eqn{K \times p}.
#' If \code{parameterWeights = NULL} default weights will be used.
#' Default weights are is 0 for the intercept weights and 1 for all other weights.
#' @param alpha the \eqn{\alpha} value 0 for group lasso, 1 for lasso, between 0 and 1 gives a sparse group lasso penalty.
#' @param standardize if TRUE the features are standardize before fitting the model. The model parameters are returned in the original scale.
#' @param lambda lambda.min relative to lambda.max or the lambda sequence for the regularization path (that is a vector or a list of vectors with the lambda sequence for the subsamples).
#' @param d length of lambda sequence (ignored if \code{length(lambda) > 1})
#' @param training a list of training samples, each item of the list corresponding to a subsample.
#' Each item in the list must be a vector with the indices of the training samples for the corresponding subsample.
#' The length of the list must equal the length of the \code{test} list.
#' @param test a list of test samples, each item of the list corresponding to a subsample.
#' Each item in the list must be vector with the indices of the test samples for the corresponding subsample.
#' The length of the list must equal the length of the \code{training} list.
#' @param intercept should the model include intercept parameters
#' @param sparse.data if TRUE \code{x} will be treated as sparse, if \code{x} is a sparse matrix it will be treated as sparse by default.
#' @param collapse if \code{TRUE} the results for each subsample will be collapse into one result (this is useful if the subsamples are not overlapping)
#' @param max.threads Deprecated (will be removed in 2018),
#' instead use \code{use_parallel = TRUE} and registre parallel backend (see package 'doParallel').
#' The maximal number of threads to be used.
#' @param use_parallel If \code{TRUE} the \code{foreach} loop will use \code{\%dopar\%}. The user must registre the parallel backend.
#' @param algorithm.config the algorithm configuration to be used.
#' @return
#' \item{link}{the linear predictors -- a list of length \code{length(test)} with each element of the list another list of length \code{length(lambda)} one item for each lambda value, with each item a matrix of size \eqn{K \times N} containing the linear predictors.}
#' \item{response}{the estimated probabilities -- a list of length \code{length(test)} with each element of the list another list of length \code{length(lambda)} one item for each lambda value, with each item a matrix of size \eqn{K \times N} containing the probabilities.}
#' \item{classes}{the estimated classes -- a list of length \code{length(test)} with each element of the list a matrix of size \eqn{N \times d} with \eqn{d=}\code{length(lambda)}.}
#' \item{features}{number of features used in the models.}
#' \item{parameters}{number of parameters used in the models.}
#' \item{classes.true}{ a list of length \code{length(training)}, containing the true classes used for estimation}
#'
#' @examples
#' data(SimData)
#'
#' # A quick look at the data
#' dim(x)
#' table(classes)
#'
#' test <- list(1:20, 21:40)
#' train <- lapply(test, function(s) (1:length(classes))[-s])
#'
#' # Run subsampling
#' # Using a lambda sequence ranging from the maximal lambda to 0.5 * maximal lambda
#' fit.sub <- msgl::subsampling(x, classes, alpha = 0.5, lambda = 0.5, training = train, test = test)
#'
#' # Print some information
#' fit.sub
#'
#' # Mean misclassification error of the tests
#' Err(fit.sub)
#'
#' # Negative log likelihood error
#' Err(fit.sub, type="loglike")
#'
#' @author Martin Vincent
#' @importFrom utils packageVersion
#' @importFrom utils packageVersion
#' @importFrom sglOptim sgl_subsampling
#' @importFrom sglOptim transpose_response_elements
#' @importFrom methods is
#' @export
subsampling <- function(x, classes,
	sampleWeights = NULL,
	grouping = NULL,
	groupWeights = NULL,
	parameterWeights = NULL,
	alpha = 0.5,
	standardize = TRUE,
	lambda,
	d = 100,
	training,
	test,
	intercept = TRUE,
	sparse.data = is(x, "sparseMatrix"),
	collapse = FALSE,
	max.threads = NULL,
	use_parallel = FALSE,
	algorithm.config = msgl.standard.config) {

	# Get call
	cl <- match.call()

	setup <- .process_args(
		x = x,
		classes = classes,
		weights = sampleWeights,
		intercept = intercept,
		grouping = grouping,
		groupWeights = groupWeights,
		parameterWeights = parameterWeights,
		standardize = standardize,
    sparse.data = sparse.data
	)

	data <- setup$data

	# print some info
	if(algorithm.config$verbose) {
		if(data$sparseX) {
			cat(paste("Running msgl subsampling with ", length(training)," subsamples (sparse design matrix)\n\n", sep=""))
		} else {
			cat(paste("Running msgl subsampling with ", length(training)," subsamples (dense design matrix)\n\n", sep=""))
		}

	print( data.frame(
		'Samples: ' = print_with_metric_prefix(data$n_samples),
		'Features: ' = print_with_metric_prefix(data$n_covariate),
		'Classes: ' = print_with_metric_prefix(data$response_dimension),
		'Groups: ' = print_with_metric_prefix(length(unique(setup$grouping))),
		'Parameters: ' = print_with_metric_prefix(length(setup$parameterWeights)),
		check.names = FALSE),
		row.names = FALSE, digits = 2, right = TRUE)
	cat("\n")
	}

	# Do subsampling
	res <- sgl_subsampling(
		module_name = setup$callsym,
		PACKAGE = "msgl",
		data = data,
		parameterGrouping = setup$grouping,
		groupWeights = setup$groupWeights,
		parameterWeights = setup$parameterWeights,
		alpha =  alpha,
		lambda = lambda,
		d = d,
		training = training,
		test = test,
		collapse = collapse,
		responses = c("link", "response", "classes"),
		max.threads = max.threads,
		use_parallel = use_parallel,
		algorithm.config = algorithm.config
	)

	### Responses

	res$classes <- lapply(res$responses$classes, function(cls) {
		newcls <- apply(cls, 2, function(x) setup$class_names[x])
		dimnames(newcls) <- dimnames(cls)
		attr(newcls, "type") <- attr(cls, "type")

		return(newcls)
	})
	attr(res$classes, "type") <- attr(res$responses$classes, "type")

	res$response <- transpose_response_elements(res$responses$response)
	res$link <- transpose_response_elements(res$responses$link)
	res$responses <- NULL

	# True classes
	res$classes.true <- lapply(test, function(sub) classes[sub])

	# Various
	res$msgl_version <- packageVersion("msgl")
	res$call <- cl

	class(res) <- "msgl"
	return(res)
}

#' Deprecated subsampling function
#'
#' @keywords internal
#' @export
msgl.subsampling <- function(x, classes,
	sampleWeights = NULL,
	grouping = NULL,
	groupWeights = NULL,
	parameterWeights = NULL,
	alpha = 0.5,
	standardize = TRUE,
	lambda,
	d = 100,
	training,
	test,
	intercept = TRUE,
	sparse.data = is(x, "sparseMatrix"),
	collapse = FALSE,
	max.threads = NULL,
	use_parallel = FALSE,
	algorithm.config = msgl.standard.config) {

	warning("msgl.subsampling( is deprecated, use msgl::subsampling")

	msgl::subsampling(
		x,
		classes,
		sampleWeights,
		grouping,
		groupWeights,
		parameterWeights,
		alpha,
		standardize,
		lambda,
		d,
		training,
		test,
		intercept,
		sparse.data,
		collapse,
		max.threads,
		use_parallel,
		algorithm.config
	)
	}
