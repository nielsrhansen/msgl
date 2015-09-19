# msgl

[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/msgl)](http://cran.r-project.org/package=msgl)
[![Travis-CI Build Status](https://travis-ci.org/vincent-dk/msgl.svg?branch=master)](https://travis-ci.org/vincent-dk/msgl)

High dimensional multiclass classification using sparse group lasso. The penalized maximum likelihood estimator for multinomial logistic regression is computed using a coordinate gradient descent algorithm.

![alt tag](https://raw.github.com/vincent-dk/msgl/master/fig1.png)
> Classification of cancer site. Error estimted by 10-fold cross validation on a data set consist of miRNA expression measurements of leaser dissected primary cancers.

**Package features includes**:

* Feature and parameter selection

* Fast

* Suitable for high dimensional multiclass classification

* Support for lasso, group lasso and sparse group lasso

* Custom grouping of features

* Sample weighting

* Individual weighting of the group and parameter penalties

## Installation

Get the released version from CRAN:

```R
install.packages("msgl")
```

Or the development version from github:

```R
# install.packages("devtools")
devtools::install_github("vincent-dk/sglOptim")
devtools::install_github("vincent-dk/msgl")
```
## Quick start

**Load your data**, containing N samples and p features (covariates):

```R
x <- # load design matrix (of size N x p) 
classes <- # load class labels (a vector of size N)
```

**Compute lambda sequence**, choos a lambda.min and an alpha (alpha = 1 for lasso, alpha = 0 for group lasso and alpha in the range (0,1) for sprase group lasso)

```R
lambda <- msgl.lambda.seq(x, classes, alpha = .5, lambda.min = 0.05)
```

**Estimate the error for each lambda value using 10 fold cross validation**
```R
fit.cv <- msgl.cv(x, classes, fold = 10, alpha = .5, lambda = lambda)
```
the output (while the algorithm is running) could look something like this:
```R
Running msgl 4 fold cross validation (dense design matrix)

 Samples:  Features:  Classes:  Groups:  Parameters: 
       119    22.284k        13  22.284k     289.692k

0% 10   20   30   40   50   60   70   80   90   100%
|----|----|----|----|----|----|----|----|----|----|
********************************************
```


**Look at the estimated missclassification errors**
```R
Err(fit.cv)
```

**or get a summery of the estimated models**
```R
fit.cv
```