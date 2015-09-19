# msgl

[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/msgl)](http://cran.r-project.org/package=msgl)
[![Travis-CI Build Status](https://travis-ci.org/vincent-dk/msgl.svg?branch=master)](https://travis-ci.org/vincent-dk/msgl)

High dimensional multiclass classification using sparse group lasso. The penalized maximum likelihood estimator for multinomial logistic regression is computed using a coordinate grdient descent algorithm.

### Classification of cancer site. Error estimted by 10-fold cross validation on a data set consist of miRNA expression measurements of leaser dissected primary cancers:
![alt tag](https://raw.github.com/vincent-dk/msgl/master/fig1.png)

## Package features includes:

* **Feature and parameter selection**:

* **Fast**:

* **Sutable for high dimensional multiclass classification**:

* **Support for lasso, group lasso and sparse group lasso**:

* **Custom grouping of features**:

* **Sample weighting**:

* **Individual weighting of the group and parameter penalties**:

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
