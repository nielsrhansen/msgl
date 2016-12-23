# High dimensional multiclass classification

[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/msgl)](http://cran.r-project.org/package=msgl)
[![Travis-CI Build Status](https://travis-ci.org/vincent-dk/msgl.svg?branch=master)](https://travis-ci.org/vincent-dk/msgl)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/vincent-dk/msgl?branch=master&svg=true)](https://ci.appveyor.com/project/vincent-dk/msgl)
[![Coverage Status](https://codecov.io/github/vincent-dk/msgl/coverage.svg?branch=master)](https://codecov.io/github/vincent-dk/msgl?branch=master)


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
## Documentation

[Quick Start (Predict primary cancer site based on microRNA measurements) ](quick-start.md)
