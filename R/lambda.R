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

#' @title Computes a lambda sequence for the regularization path
#'
#' @description
#' Computes a decreasing lambda sequence of length \code{d}.
#' The sequence ranges from a data determined maximal lambda \eqn{\lambda_\textrm{max}} to the user inputed \code{lambda.min}.
#'
#' @param x design matrix, matrix of size \eqn{N \times p}.
#' @param classes classes, factor of length \eqn{N}.
#' @param sampleWeights sample weights, a vector of length \eqn{N}.
#' @param grouping grouping of features, a vector of length \eqn{p}. Each element of the vector specifying the group of the covariate.
#' @param groupWeights the group weights, a vector of length \eqn{m+1} (the number of groups).
#' The first element of the vector is the intercept weight.
#' If \code{groupWeights = NULL} default weights will be used.
#' Default weights are 0 for the intercept and \deqn{\sqrt{K\cdot\textrm{number of features in the group}}} for all other weights.
#' @param parameterWeights a matrix of size \eqn{K \times (p+1)}.
#' The first column of the matrix is the intercept weights.
#' Default weights are is 0 for the intercept weights and 1 for all other weights.
#' @param alpha the \eqn{\alpha} value 0 for group lasso, 1 for lasso, between 0 and 1 gives a sparse group lasso penalty.
#' @param d the length of lambda sequence
#' @param standardize if TRUE the features are standardize before fitting the model. The model parameters are returned in the original scale.
#' @param lambda.min the smallest lambda value in the computed sequence.
#' @param intercept should the model include intercept parameters
#' @param sparse.data if TRUE \code{x} will be treated as sparse, if \code{x} is a sparse matrix it will be treated as sparse by default.
#' @param lambda.min.rel is lambda.min relative to lambda.max ? (i.e. actual lambda min used is \code{lambda.min*lambda.max}, with \code{lambda.max} the computed maximal lambda value)
#' @param algorithm.config the algorithm configuration to be used.
#' @return a vector of length \code{d} containing the computed lambda sequence.
#' @examples
#' data(SimData)
#'
#' # A quick look at the data
#' dim(x)
#' table(classes)
#'
#' lambda <- msgl::lambda(x, classes, alpha = .5, d = 100, lambda.min = 0.01)
#' @author Martin Vincent
#' @importFrom methods is
#' @importFrom sglOptim sgl_lambda_sequence
#' @importFrom sglOptim transpose_response_elements
#' @export
lambda <- function(
  x,
  classes,
  sampleWeights = NULL,
  grouping = NULL,
  groupWeights = NULL,
  parameterWeights = NULL,
  alpha = 0.5,
  d = 100L,
  standardize = TRUE,
  lambda.min,
  intercept = TRUE,
  sparse.data = is(x, "sparseMatrix"),
  lambda.min.rel = FALSE,
  algorithm.config = msgl.standard.config) {


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

  lambda <- sgl_lambda_sequence(
    module_name = setup$callsym,
    PACKAGE = "msgl",
    data = data,
    parameterGrouping = setup$grouping,
    groupWeights = setup$groupWeights,
    parameterWeights = setup$parameterWeights,
    alpha = alpha,
    d = d,
    lambda.min = lambda.min,
    algorithm.config = algorithm.config,
    lambda.min.rel = lambda.min.rel
  )

  return(lambda)
}


#' C interface
#'
#' @keywords internal
#' @export
msgl_dense_sgl_lambda_R <- function(
  data,
  block_dim,
  groupWeights,
  parameterWeights,
  alpha,
  d,
  lambda.min,
  lambda.min.rel,
  algorithm.config) {
  
  .Call(msgl_dense_sgl_lambda, PACKAGE = "msgl",
        data,
        block_dim,
        groupWeights,
        parameterWeights,
        alpha,
        d,
        lambda.min,
        lambda.min.rel,
        algorithm.config
  )
}

#' C interface
#'
#' @keywords internal
#' @export
msgl_sparse_sgl_lambda_R <- function(
  data,
  block_dim,
  groupWeights,
  parameterWeights,
  alpha,
  d,
  lambda.min,
  lambda.min.rel,
  algorithm.config) {
  
  .Call(msgl_sparse_sgl_lambda, PACKAGE = "msgl",
        data,
        block_dim,
        groupWeights,
        parameterWeights,
        alpha,
        d,
        lambda.min,
        lambda.min.rel,
        algorithm.config
  )
}


#' Deprecated lambda function
#'
#' @keywords internal
#' @export
msgl.lambda.seq <- function(
  x,
  classes,
  sampleWeights = NULL,
  grouping = NULL,
  groupWeights = NULL,
  parameterWeights = NULL,
  alpha = 0.5,
  d = 100L,
  standardize = TRUE,
  lambda.min,
  intercept = TRUE,
  sparse.data = is(x, "sparseMatrix"),
  lambda.min.rel = FALSE,
  algorithm.config = msgl.standard.config) {

  warning("msgl.lambda.seq is deprecated, use msgl::lambda")

  msgl::lambda(
    x,
    classes,
    sampleWeights,
    grouping,
    groupWeights,
    parameterWeights,
    alpha,
    d,
    standardize,
    lambda.min,
    intercept,
    sparse.data,
    lambda.min.rel,
    algorithm.config
  )
  }
