#
#     Description of this R script:
#     R interface for multinomial sparse group lasso rutines.
#
#     Intended for use with R.
#     Copyright (C) 2014 Martin Vincent
#
#     This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
#
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <http://www.gnu.org/licenses/>
#

#' @title Cross Validation
#'
#' @description
#' Multinomial sparse group lasso cross validation, with or without parallel backend.
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
#' Default weights are is 0 for the intercept weights and 1 for all other weights.#'
#' @param alpha the \eqn{\alpha} value 0 for group lasso, 1 for lasso, between 0 and 1 gives a sparse group lasso penalty.
#' @param standardize if TRUE the features are standardize before fitting the model. The model parameters are returned in the original scale.
#' @param lambda lambda.min relative to lambda.max or the lambda sequence for the regularization path.
#' @param d length of lambda sequence (ignored if \code{length(lambda) > 1})
#' @param fold the fold of the cross validation, an integer larger than \eqn{1} and less than \eqn{N+1}. Ignored if \code{cv.indices != NULL}.
#' If \code{fold}\eqn{\le}\code{max(table(classes))} then the data will be split into \code{fold} disjoint subsets keeping the ration of classes approximately equal.
#' Otherwise the data will be split into \code{fold} disjoint subsets without keeping the ration fixed.
#' @param cv.indices a list of indices of a cross validation splitting.
#' If \code{cv.indices = NULL} then a random splitting will be generated using the \code{fold} argument.
#' @param intercept should the model include intercept parameters
#' @param sparse.data if TRUE \code{x} will be treated as sparse, if \code{x} is a sparse matrix it will be treated as sparse by default.
#' @param max.threads Deprecated (will be removed in 2018),
#' instead use \code{use_parallel = TRUE} and registre parallel backend (see package 'doParallel').
#' The maximal number of threads to be used.
#' @param use_parallel If \code{TRUE} the \code{foreach} loop will use \code{\%dopar\%}. The user must registre the parallel backend.
#' @param algorithm.config the algorithm configuration to be used.
#' @return
#' \item{link}{the linear predictors -- a list of length \code{length(lambda)} one item for each lambda value, with each item a matrix of size \eqn{K \times N} containing the linear predictors.}
#' \item{response}{the estimated probabilities - a list of length \code{length(lambda)} one item for each lambda value, with each item a matrix of size \eqn{K \times N} containing the probabilities.}
#' \item{classes}{the estimated classes - a matrix of size \eqn{N \times d} with \eqn{d=}\code{length(lambda)}.}
#' \item{cv.indices}{the cross validation splitting used.}
#' \item{features}{number of features used in the models.}
#' \item{parameters}{number of parameters used in the models.}
#' \item{classes.true}{the true classes used for estimation, this is equal to the \code{classes} argument}
#'
#' @examples
#' data(SimData)
#'
#' # A quick look at the data
#' dim(x)
#' table(classes)
#'
#' # Setup clusters
#' cl <- makeCluster(2)
#' registerDoParallel(cl)
#'
#' # Run cross validation using 2 clusters
#' # Using a lambda sequence ranging from the maximal lambda to 0.7 * maximal lambda
#' fit.cv <- msgl::cv(x, classes, alpha = 0.5, lambda = 0.7, use_parallel = TRUE)
#'
#' # Stop clusters
#' stopCluster(cl)
#'
#' # Print some information
#' fit.cv
#'
#' # Cross validation errors (estimated expected generalization error)
#' # Misclassification rate
#' Err(fit.cv)
#'
#' # Negative log likelihood error
#' Err(fit.cv, type="loglike")
#'
#' @author Martin Vincent
#' @importFrom utils packageVersion
#' @importFrom methods is
#' @importFrom sglOptim sgl_cv
#' @importFrom sglOptim transpose_response_elements
#' @export
cv <- function(x, classes,
	sampleWeights = NULL,
	grouping = NULL,
	groupWeights = NULL,
	parameterWeights = NULL,
	alpha = 0.5,
	standardize = TRUE,
	lambda,
	d = 100,
	fold = 10L,
	cv.indices = list(),
	intercept = TRUE,
	sparse.data = is(x, "sparseMatrix"),
	max.threads = NULL,
	use_parallel = FALSE,
	algorithm.config = msgl.standard.config) {

	# Get call
	cl <- match.call()

	if(fold > min(table(classes))) {
		warning("fold larger than the number of samples in the smalest group")
	}

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

	# call sglOptim function
	if(algorithm.config$verbose) {

		if(data$sparseX) {
			cat(paste("Running msgl ", max(length(cv.indices), fold)," fold cross validation (sparse design matrix)\n\n", sep=""))
		} else {
			cat(paste("Running msgl ", max(length(cv.indices), fold)," fold cross validation (dense design matrix)\n\n", sep=""))
		}

		print(data.frame(
			'Samples: ' = print_with_metric_prefix(data$n_samples),
			'Features: ' = print_with_metric_prefix(data$n_covariate),
			'Classes: ' = print_with_metric_prefix(data$response_dimension),
			'Groups: ' = print_with_metric_prefix(length(unique(setup$grouping))),
			'Parameters: ' = print_with_metric_prefix(length(setup$parameterWeights)),
			check.names = FALSE),
			row.names = FALSE, digits = 2, right = TRUE)
		cat("\n")
	}


	res <- sgl_cv(
		module_name = setup$callsym,
		PACKAGE = "msgl",
		data = data,
		parameterGrouping = setup$grouping,
		groupWeights = setup$groupWeights,
		parameterWeights = setup$parameterWeights,
		alpha =  alpha,
		lambda = lambda,
		d = d,
		fold = fold,
		cv.indices = cv.indices,
		responses = c("link", "response", "classes"),
		max.threads = max.threads,
		use_parallel = use_parallel,
		algorithm.config = algorithm.config
	)

  ### Responses
	res$classes <- apply(res$responses$classes, 2, function(x) setup$class_names[x])
	dimnames(res$classes) <- dimnames(res$responses$classes)
	attr(res$classes, "type") <- attr(res$responses$classes, "type")

	res$response <- transpose_response_elements(res$responses$response)
	res$link <- transpose_response_elements(res$responses$link)
	res$responses <- NULL

	# True classes
	res$classes.true <- classes

	# Various
	res$msgl_version <- packageVersion("msgl")
	res$call <- cl

	class(res) <- "msgl"
	return(res)
}

#' Deprecated cv function
#'
#' @keywords internal
#' @export
msgl.cv <- function(x, classes,
	sampleWeights = NULL,
	grouping = NULL,
	groupWeights = NULL,
	parameterWeights = NULL,
	alpha = 0.5,
	standardize = TRUE,
	lambda,
	d = 100,
	fold = 10L,
	cv.indices = list(),
	intercept = TRUE,
	sparse.data = is(x, "sparseMatrix"),
	max.threads = NULL,
	use_parallel = FALSE,
	algorithm.config = msgl.standard.config) {

	warning("msgl.cv is deprecated, use msgl::cv")

	msgl::cv(
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
		fold,
		cv.indices,
		intercept,
		sparse.data,
		max.threads,
		use_parallel,
		algorithm.config)
	}
