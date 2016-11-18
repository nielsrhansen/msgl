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

.process_args <- function(
  x,
  classes,
  weights,
  intercept,
  grouping,
  groupWeights,
  parameterWeights,
  standardize,
  sparse.data) {

	#Check dimensions
	if(nrow(x) != length(classes)) {
		stop("the number of rows in x must match the length of classes")
	}

  if(sum(is.na(classes)) > 0) {
  		stop("classes contains NA values")
  }

	# Default values
	if(is.null(grouping)) {
		grouping <- factor(1:ncol(x))
	} else {
		# ensure factor
		grouping <- factor(grouping)
	}

  if( is.null(weights) ) {
    weights <- rep(1/nrow(x), nrow(x))
  }

	# cast
	classes <- factor(classes)

	if(is.null(groupWeights)) {
		groupWeights <- c(sqrt(length(levels(classes))*table(grouping)))
	}

	if( is.null(parameterWeights) ) {
		parameterWeights <-  matrix(1, nrow = length(levels(classes)), ncol = ncol(x))
	}

  if( is.null(dimnames(parameterWeights)) ) {
    dimnames(parameterWeights) <- list(levels(classes), colnames(x))
  }

	# Standardize
	if(standardize) {

		if(sparse.data) {
			x.scale <- sqrt(colMeans(x*x) - colMeans(x)^2)
			x.center <- rep(0, length(x.scale))
			x <- x%*%Diagonal(x=1/x.scale)
		} else {
			x <- scale(x, if(sparse.data) FALSE else TRUE, TRUE)
			x.scale <- attr(x, "scaled:scale")
			x.center <- if(sparse.data) rep(0, length(x.scale)) else attr(x, "scaled:center")
		}
	}

  if(intercept) {

    # add intercept

    if( is.null(colnames(x)) ) {
		  x <- cBind(rep(1, nrow(x)), x)
	  } else {
		  x <- cBind(Intercept = rep(1, nrow(x)), x)
	  }

    groupWeights <- c(0, groupWeights)

    parameterWeights <- cbind(rep(0, length(levels(classes))), parameterWeights)
    colnames(parameterWeights)[1] <- "Intercept"

    grouping <- factor(c("Intercept", as.character(grouping)), levels = c("Intercept", levels(grouping)))

  }

  # create data
data <- create.sgldata(
  x = x,
  y = classes,
  sparseX = sparse.data,
  sparseY = FALSE
)

data <- add_data(data, weights, "W")

# Call sglOptim function
callsym <- .get_callsym(data)

setup <- list()
setup$data <- data
setup$callsym <- callsym
setup$grouping <- grouping
setup$groupWeights <- groupWeights
setup$parameterWeights <- parameterWeights

if(standardize) {
  setup$x.scale <- x.scale
  setup$x.center <- x.center
}

return(setup)

}

# Match with MODULE_NAME in logitsgl.cpp
.get_callsym <- function(data) {

  obj <- "msgl"

	return( paste(obj, if(data$sparseX) "sparse" else "dense", sep="_") )
}
