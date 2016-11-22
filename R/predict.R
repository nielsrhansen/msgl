#' @title Predict
#'
#' @description
#' Computes the linear predictors, the estimated probabilities and the estimated classes for a new data set.
#'
#' @param object an object of class msgl, produced with \code{msgl}.
#' @param x a data matrix of size \eqn{N_\textrm{new} \times p}.
#' @param sparse.data if TRUE \code{x} will be treated as sparse, if \code{x} is a sparse matrix it will be treated as sparse by default.
#' @param ... ignored.
#' @return
#' \item{link}{the linear predictors -- a list of length \code{length(fit$beta)} one item for each model, with each item a matrix of size \eqn{K \times N_\textrm{new}} containing the linear predictors.}
#' \item{response}{the estimated probabilities -- a list of length \code{length(fit$beta)} one item for each model, with each item a matrix of size \eqn{K \times N_\textrm{new}} containing the probabilities.}
#' \item{classes}{the estimated classes -- a matrix of size \eqn{N_\textrm{new} \times d} with \eqn{d=}\code{length(fit$beta)}.}
#' @examples
#' data(SimData)
#'
#' x.1 <- sim.data$x[1:50,]
#' x.2 <- sim.data$x[51:100,]
#'
#' classes.1 <- sim.data$classes[1:50]
#' classes.2 <- sim.data$classes[51:100]
#'
#' lambda <- msgl.lambda.seq(x.1, classes.1, alpha = .5, d = 50, lambda.min = 0.05)
#' fit <- msgl(x.1, classes.1, alpha = .5, lambda = lambda)
#'
#' # Predict classes of new data set x.2
#' res <- predict(fit, x.2)
#'
#' # The error rates of the models
#' Err(res, classes = classes.2)
#'
#' # The predicted classes for model 20
#' res$classes[,20]
#'
#' @author Martin Vincent
#' @importFrom utils packageVersion
#' @importFrom methods is
#' @importFrom methods as
#' @method predict msgl
#' @export
#' @useDynLib msgl, .registration=TRUE
predict.msgl <- function(object, x, sparse.data = is(x, "sparseMatrix"), ...) {

	# Get call
	cl <- match.call()

	if(is.null(object$beta)) stop("No models found -- missing beta")

	# add intercept
	x <- cBind(Intercept = rep(1, nrow(x)), x)

	#Check dimension of x
	if(dim(object$beta[[2]])[2] != ncol(x)) stop("x has wrong dimension")

	data <- create.sgldata(x, NULL, sparseX = sparse.data, sparseY = FALSE)

	res <- sgl_predict(
		module_name = if(sparse.data) "msgl_sparse" else "msgl_dense",
		PACKAGE = "msgl",
		object = object,
		data = data,
		responses = c("link", "response", "classes")
	)

	### Responses
	res$classes <- apply(res$responses$classes, 2, function(x) levels(object$classes.true)[x])
	dimnames(res$classes) <- dimnames(res$responses$classes)
	attr(res$classes, "type") <- attr(res$responses$classes, "type")

	res$response <- transpose_response_elements(res$responses$response)
	res$link <- transpose_response_elements(res$responses$link)
	res$responses <- NULL

	# Various
	res$msgl_version <- packageVersion("msgl")
	res$call <- cl

	class(res) <- "msgl"
	return(res)
}
