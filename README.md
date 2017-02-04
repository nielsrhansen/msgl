High Dimensional Multiclass Classification
------------------------------------------

[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/msgl)](http://cran.r-project.org/package=msgl) [![Travis-CI Build Status](https://travis-ci.org/vincent-dk/msgl.svg?branch=develop)](https://travis-ci.org/vincent-dk/msgl) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/vincent-dk/msgl?branch=master&svg=true)](https://ci.appveyor.com/project/vincent-dk/msgl) [![Coverage Status](https://codecov.io/github/vincent-dk/msgl/coverage.svg?branch=master)](https://codecov.io/github/vincent-dk/msgl?branch=master)

Multi-class classification with feature and parameter selection using sparse group lasso. Suitable for high dimensional problems.

This is the **development version** of R package **sglOptim version 2.3.7**.

### R-package Overview

This package implements procedures for working with multinomial logistic regression models using sparse group lasso. This includes procedures for fitting and cross validating sparse models in a high dimensional setup. See the [Quick Start (Predict primary cancer site based on microRNA measurements)](quick-start.md) for an example of a traditional workflow consisting of 1) model selection and assessment using cross validation, 2) estimation of a final model and 3) using the selected model for carrying out predictions on new data.

![alt tag](https://raw.github.com/vincent-dk/msgl/master/fig1.png)

> Classification of cancer site. Error estimted by 10-fold cross validation on a data set consist of miRNA expression measurements of leaser dissected primary cancers.

**Package highlights:**

-   Feature and parameter selection
-   Fast coordinate gradient descent algorithm
-   Suitable for high dimensional multiclass classification
-   Support for lasso, group lasso and sparse group lasso
-   Supports custom grouping of features
-   Supports sample weighting
-   Supports individual weighting of the group and parameter penalties

The penalized maximum likelihood estimator for multinomial logistic regression is computed using a coordinate gradient descent algorithm via the [sglOptim](https://github.com/vincent-dk/sglOptim) optimizer. Use of parallel computing for cross validation and subsampling is supported through the [foreach](https://cran.r-project.org/package=foreach) and [doParallel](https://cran.r-project.org/package=doParallel) packages.

### Status

The package is under active development with releases to CRAN about ones or twice each year.

### Installation

Install the released version from CRAN:

``` r
install.packages("msgl")
```

Install the release candidate from GitHub:

``` r
# install.packages("devtools")
devtools::install_github("vincent-dk/sglOptim")
devtools::install_github("vincent-dk/msgl")
```

Install the development version from GitHub:

``` r
# install.packages("devtools")
devtools::install_github("vincent-dk/sglOptim", ref = "develop")
devtools::install_github("vincent-dk/msgl", ref = "develop")
```

### Minimal Example

``` r
library(msgl)

# Load some data
data(PrimaryCancers)

# Setup 2 parallel units
cl <- makeCluster(2)
registerDoParallel(cl)

# Do 10-fold cross validation on 100 models with increasing complexity, using the 2 parallel units
fit.cv <- msgl::cv(
  x = x,
  classes = classes,
  alpha = 0.5,
  lambda = 0.5,
  use_parallel = TRUE
)
```

    ## Running msgl 10 fold cross validation (dense design matrix)
    ## 
    ##  Samples:  Features:  Classes:  Groups:  Parameters: 
    ##        165        372         9      372       3.348k

``` r
stopCluster(cl)

# Print information about models
# and cross validation errors
fit.cv
```

    ## 
    ## Call:
    ## msgl::cv(x = x, classes = classes, alpha = 0.5, lambda = 0.5, 
    ##     use_parallel = TRUE)
    ## 
    ## Models:
    ## 
    ##  Index:  Lambda:  Features:  Parameters:  Error: 
    ##        1     1.00        1.5         11.1    0.93
    ##       20     0.88        4.8         32.4    0.74
    ##       40     0.76        8.8         51.4    0.62
    ##       60     0.66       11.2         64.8    0.50
    ##       80     0.58       15.2         87.1    0.41
    ##      100     0.50       20.5        113.1    0.37
    ## 
    ## Best model:
    ## 
    ##  Index:  Lambda:  Features:  Parameters:  Error: 
    ##       95     0.52       18.8          105    0.37

### Documentation

-   R package documentation
-   [Quick Start (Predict primary cancer site based on microRNA measurements)](quick-start.md)
-   [Sparse group lasso and high dimensional multinomial classification](http://dx.doi.org/10.1016/j.csda.2013.06.004) paper in Computational Statistics & Data Analysis

### Author

Martin Vincent

### License

GPL (&gt;=2)
