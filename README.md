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
## Quick Start

### 1. Load the msgl library in R
```R
library(msgl)
```

### 2. Load your data
Load data containing N samples and p features (covariates):

```R
x <- # load design matrix (of size N x p) 
classes <- # load class labels (a vector of size N)
```

### 3. Compute lambda sequence
Choose a lambda.min and an alpha. With alpha = 1 for lasso, alpha = 0 for group lasso and alpha in the range (0,1) for spares group lasso. 

```R
lambda <- msgl.lambda.seq(x, classes, alpha = 0.25, lambda.min = 1e-4)
```

The user specified lambda.min should be less than the compute lambda.max. Lambda max is the lambda at which the first penalized parameter becomes non-zero. A smaller lambda.min will take longer to fit and include more features.

```R
lambda[1] # lambda.max
```

### 4. Estimate error using cross validation

Use 'msgl.cv' to estimate the error for each lambda value and for finding an optimal lambda. The following command will run a 10 fold cross validation for each lambda value in the lambda sequence using maximally 5 threads. 

```R
fit.cv <- msgl.cv(x, classes, fold = 10, alpha = 0.25, lambda = lambda, max.threads = 5)
```
the output (while the algorithm is running) would look something like this:
```
Running msgl 10 fold cross validation (dense design matrix)

 Samples:  Features:  Classes:  Groups:  Parameters: 
       119    22.284k        13  22.284k     289.692k

0% 10   20   30   40   50   60   70   80   90   100%
|----|----|----|----|----|----|----|----|----|----|
********************************************
```

**Get a summery of the validated models.**
We have now cross validated the models corresponding to the lambda values, one model for each lambda value. We may get a summery of this validation by doing:
```R
fit.cv
```
this would give something like this:
```
Call:
msgl.cv(x = x, classes = classes, alpha = 0.25, lambda = lambda, 
    fold = 10, max.threads = 5)

Models:

 Index:  Lambda:  Features:  Parameters:  Error: 
      20  0.03084       65.5       605.75    0.34
      40  0.00736        111       1.077k    0.23
      60  0.00176        133       1.301k    0.21
      80  0.00042      143.5       1.403k    0.21
     100  0.00010        152        1.48k    0.23

Best model:

 Index:  Lambda:  Features:  Parameters:  Error: 
      44   0.0055      116.5       1.132k    0.21
```

Hence, the best model is obtained using lambda index 44 and it has a cross validation error of 0.21. The expected number of features is 116.5 and the expected number of parameters is 1.132k.

### 5. Fit the final model

Use msgl to fit a final model.
```R
fit <- msgl(x, classes, alpha = 0.25, lambda = lambda)
```
**Get a summery of the estimated models**
```R
fit 
```
this would look like this:
```
Call:
msgl(x = x, classes = classes, alpha = 0.25, lambda = lambda)

Models:

 Index:  Lambda:  Features:  Parameters: 
      20  0.03084         63          583
      40  0.00736        122        1.18k
      60  0.00176        147       1.444k
      80  0.00042        163       1.609k
     100  0.00010        167       1.648k
```

**Take a look at the estimated models.**
As we saw in the previous step the model with index 44 had the best cross validation error, we may take a look at the included features using the command:
```R
features(fit)[[44]] # Non-zero features in model 44
```
this would look something like this (with the feature names given as the column names of the design matrix):
```
  [1] "Intercept"    "200003_s_at"   "200061_s_at"   "200076_s_at"  "200089_s_at"           
  [6] "200650_s_at"  "200666_s_at"   "201105_at"     "201224_s_at"  "201275_at"             

                                ... 

[126] "37966_at"     "39854_r_at"    "AFFX-BioC-5_at"   "AFFX-r2-Ec-bioC-3_at"   "AFFX-r2-Ec-bioD-3_at"  
[131] "AFFX-r2-Hs18SrRNA-5_at"
```
Hence 131 features are included in the model, a bit more than expected based on the cross validation estimate. 

We may also take a look at the estimate parameters (or coefficients)

```R
coef(fit, 44) # Non-zero parameters of model 44
```
the first 5 columns of this matrix will look something like this (in this case the classes where muscle diseases)
```
                                         Intercept   200003_s_at  200061_s_at  200076_s_at  200089_s_at
Acute quadriplegic myopathy             -0.7595439  8.605595e-03  0.001195788 -0.025151838  .          
AD Emery Dreifuss muscular dystrophy    -0.2768372 -1.231456e-02  .           -0.104154016 -0.004651455
Amyotrophic lateral sclerosis           -3.7515211  4.580069e-02 -0.044087480  0.003927752  0.148530249
Becker muscular dystrophy               -4.6062349 -6.996638e-03 -0.005433472  0.148216836  .          
Duchenne muscular dystrophy              2.3884725  2.203010e-02  0.025693941  .            0.019274633
Fascioscapulohumeral muscular dystrophy -1.0911442 -5.787912e-03  .           -0.002919087 -0.026420157
Hereditary spastic paraplegia (SPG4)     5.3661992  7.262152e-05 -0.055266485 -0.002127937 -0.019862967
Juvenile dermatomyositis                -0.8852379  4.006304e-03 -0.005916141 -0.012541976 -0.025205457
LGMD2A                                   4.2178767 -1.439988e-02  .            .           -0.010690382
LGMD2B                                  -0.9687094  .             0.015766030  0.164538540 -0.006691633
LGMD2I (FKRP)                           -5.0716302  .             0.037353123  0.045332682  0.009983035
Normal volunteer                         5.9397066 -2.024757e-02  0.030672820 -0.032569708  0.004009700
XR Emery Dreifuss muscular dystrophy     1.4807772 -1.975693e-02  .           -0.140377634 -0.049209029
```

If we count the total number of non-zero parameters in the model we get, in this case, 1.278k, which is slightly higher than the expected based on the cross validation estimate. 

### 6. Use your model for predictions

**Load test data** containing M samples and p features.
```R
x.test <- # load matrix with test data (of size M x p) 
```
Use the final model to predict the classes of the M samples in x.test.
```R
res <- predict(fit, x.test)

res$classes[,44] # Classes predicted by model 44
```

We may also get the estimated probabilities for each of the classes
```R
res$response[[44]]
```
the first 5 columns of this matrix will look something like this
```
                                           Test1       Test2        Test3        Test4       Test5
Acute quadriplegic myopathy             0.001885606 0.0016630587 0.0021536369 0.002416934 0.003365350
AD Emery Dreifuss muscular dystrophy    0.002486874 0.0008263667 0.0015181437 0.002503996 0.004323145
Amyotrophic lateral sclerosis           0.002888782 0.0012546621 0.0016423193 0.005565814 0.002591027
Becker muscular dystrophy               0.003976607 0.0024990435 0.0015403003 0.004675525 0.001710981
Duchenne muscular dystrophy             0.003232716 0.0033314734 0.0019272194 0.001995846 0.005322838
Fascioscapulohumeral muscular dystrophy 0.039077792 0.0083523952 0.0103045595 0.059832533 0.056302114
Hereditary spastic paraplegia (SPG4)    0.001406169 0.0020898848 0.0034977865 0.001520512 0.001634795
Juvenile dermatomyositis                0.005931747 0.0019943092 0.0023673906 0.002307952 0.005480081
LGMD2A                                  0.002498256 0.0026520844 0.0032747764 0.004248402 0.025764920
LGMD2B                                  0.001558425 0.0007249773 0.0003026516 0.006859840 0.006717150
LGMD2I (FKRP)                           0.003497491 0.0012573832 0.0033873250 0.004249424 0.006976693
Normal volunteer                        0.920058602 0.9671300490 0.9612278633 0.889420176 0.871759173
XR Emery Dreifuss muscular dystrophy    0.011500932 0.0062243124 0.0068560276 0.014403048 0.008051732
```
all 5 "Normal volunteer".

