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
fit.cv <- msgl.cv(x, classes, fold = 10, alpha = .5, lambda = lambda, max.threads = 5)
```
the output (while the algorithm is running) could look something like this:
```
Running msgl 10 fold cross validation (dense design matrix)

 Samples:  Features:  Classes:  Groups:  Parameters: 
       119    22.284k        13  22.284k     289.692k

0% 10   20   30   40   50   60   70   80   90   100%
|----|----|----|----|----|----|----|----|----|----|
********************************************
```

**Get a summery of the estimated models**
```R
fit.cv
```
this could look like this:
```
Call:
msgl.cv(x = x, classes = classes, alpha = 0.5, lambda = lambda, 
    fold = 10, max.threads = 5)

Models:

 Index:  Lambda:  Features:  Parameters:  Error: 
      20  0.02718       70.5        916.5    0.30
      40  0.00669        123       1.599k    0.22
      60  0.00165      139.5       1.813k    0.19
      80  0.00041        152       1.976k    0.19
     100  0.00010        159       2.067k    0.20

Best model:

 Index:  Lambda:  Features:  Parameters:  Error: 
      52   0.0029      133.5       1.736k    0.19
```