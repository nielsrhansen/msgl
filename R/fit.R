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

#' @title Fit a multinomial sparse group lasso regularization path.
#'
#' @description
#' Fit a sequence of multinomial logistic regression models using sparse group lasso, group lasso or lasso.
#' In addition to the standard parameter grouping the algorithm supports further grouping of the features.
#'
#' @details
#' For a classification problem with  \eqn{K} classes and \eqn{p} features (covariates) dived into \eqn{m} groups.
#' This function computes a sequence of minimizers (one for each lambda given in the \code{lambda} argument) of
#' \deqn{\hat R(\beta) + \lambda \left( (1-\alpha) \sum_{J=1}^m \gamma_J \|\beta^{(J)}\|_2 + \alpha \sum_{i=1}^{n} \xi_i |\beta_i| \right)}
#' where \eqn{\hat R} is the weighted empirical log-likelihood risk of the multinomial regression model.
#' The vector \eqn{\beta^{(J)}} denotes the parameters associated with the \eqn{J}'th group of features
#' (default is one covariate per group, hence the default dimension of \eqn{\beta^{(J)}} is \eqn{K}).
#' The group weights \eqn{\gamma \in [0,\infty)^m} and parameter weights \eqn{\xi \in [0,\infty)^n} may be explicitly specified.
#'
#' @param x design matrix, matrix of size \eqn{N \times p}.
#' @param classes classes, factor of length \eqn{N}.
#' @param sampleWeights sample weights, a vector of length \eqn{N}.
#' @param grouping grouping of features, a vector of length \eqn{p}. Each element of the vector specifying the group of the feature.
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
#' @param lambda lambda.min relative to lambda.max or the lambda sequence for the regularization path.
#' @param d length of lambda sequence (ignored if \code{length(lambda) > 1})
#' @param return_indices the indices of lambda values for which to return a the fitted parameters.
#' @param intercept should the model fit include intercept parameters (note that due to standardization the returned beta matrix will always have an intercept column)
#' @param sparse.data if TRUE \code{x} will be treated as sparse, if \code{x} is a sparse matrix it will be treated as sparse by default.
#' @param algorithm.config the algorithm configuration to be used.
#' @return
#' \item{beta}{the fitted parameters -- a list of length \code{length(lambda)} with each entry a matrix of size \eqn{K\times (p+1)} holding the fitted parameters}
#' \item{loss}{the values of the loss function}
#' \item{objective}{the values of the objective function (i.e. loss + penalty)}
#' \item{lambda}{the lambda values used}
#' \item{classes.true}{the true classes used for estimation, this is equal to the \code{classes} argument}
#' @examples
#' data(SimData)
#' x <- sim.data$x
#' classes <- sim.data$classes
#'
#' fit <- msgl(x, classes, alpha = 0.5, lambda = 0.5)
#'
#' # Print some information about the fit
#' fit
#'
#' # Model 10, i.e. the model corresponding to lambda[10]
#' models(fit)[[10]]
#'
#' # The nonzero features of model 10
#' features(fit)[[10]]
#'
#' # The nonzero parameters of model 10
#' parameters(fit)[[10]]
#'
#' # The training errors of the models.
#' Err(fit, x)
#' # Note: For high dimensional models the training errors are almost always over optimistic,
#' # instead use msgl.cv to estimate the expected errors by cross validation
#'
#' @author Martin Vincent
#' @importFrom utils packageVersion
#' @importFrom methods is
#' @export
#' @useDynLib msgl, .registration=TRUE
#' @import Matrix
msgl <- function(
	x,
	classes,
	sampleWeights = NULL,
	grouping = NULL,
	groupWeights = NULL,
	parameterWeights = NULL,
	alpha = 0.5,
	standardize = TRUE,
	lambda,
	d = 100,
	return_indices = NULL,
	intercept = TRUE,
	sparse.data = is(x, "sparseMatrix"),
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

	# call sglOptim function
	if(algorithm.config$verbose) {
		if(data$sparseX) {
			cat("\nRunning msgl (sparse design matrix)\n\n")
		} else {
			cat("\nRunning msgl (dense design matrix) \n\n")
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

# Call sglOptim
res <- sgl_fit(
	module_name = setup$callsym,
	PACKAGE = "msgl",
	data = data,
	parameterGrouping = setup$grouping,
	groupWeights = setup$groupWeights,
	parameterWeights = setup$parameterWeights,
	alpha = alpha,
	lambda = lambda,
	d = d,
	return_indices = return_indices,
	algorithm.config = algorithm.config
)

# Convert beta back to the org scale
if(standardize) {
	res$beta <- .to_org_scale(
		beta = res$beta,
		x.scale = setup$x.scale,
		x.center = setup$x.center
	)
}

res$classes.true <- classes

res$sparse.data <- data$sparseX

# Various
res$msgl_version <- packageVersion("msgl")
res$call <- cl

class(res) <- "msgl"
return(res)

}

.to_org_scale <- function(beta, x.scale, x.center) {

	for(l in 1:length(beta)) {

    beta.org <- t(t(beta[[l]])*c(1,1/x.scale))
    beta.org[,1] <- beta.org[,1] - rowSums(t(t(beta[[l]][,-1])*(x.center/x.scale)))

    beta[[l]] <- beta.org
	}

	return(beta)
}


#' Simulated data set
#'
#' The use of this data set is only intended for testing and examples.
#' The data set contains 100 simulated samples grouped into 10 classes.
#' For each sample 400 features have been simulated.
#'
#' @name sim.data
#' @docType data
#' @keywords data
NULL
