Quick Start (for msgl version 2.3.1)
------------------------------------

### 1. Load the msgl library in R

``` r
library(msgl)
```

### 2. Load your data

Load data containing N samples and p features (covariates):

``` r
x <- # load design matrix (of size N x p)
classes <- # load class labels (a vector of size N)
```

For the purpose of this tutorial we will load a data set consisting of microRNA normalized expression measurements of primary cancer samples.

``` r
data(PrimaryCancers)
x[1:5,1:5]
```

    ##              let.7a     let.7c     let.7d     let.7e       let.7f
    ## P-544-ME -1.1052510 -0.9213983 -0.7200146 -0.9448098 -0.591417505
    ## P-554-NW -1.0956835 -1.0879221 -0.6100223 -0.9538088 -0.554779014
    ## P-559-OI -1.1271169 -1.0914447 -0.6889379 -1.0823322 -0.736167409
    ## P-564-MO -1.2465982 -1.2719367 -0.7614792 -1.2006796 -0.784319518
    ## P-579-MY -0.6194332 -0.4971233 -0.5169694 -0.9004003  0.009509523

``` r
dim(x)
```

    ## [1] 165 371

``` r
table(classes)
```

    ## classes
    ##    Breast       CCA Cirrhosis       CRC        EG       HCC     Liver 
    ##        17        20        17        20        18        17        20 
    ##  Pancreas  Squamous 
    ##        20        16

Hence, p = 384, N = 165 and the number of classes K = 9, this implies that the multinomial classification model has 9\*(384+1) = 3465 parameters.

Let us take out a small test set:

``` r
idx <- 1:10
x.test <- x[idx,]
x <- x[-idx,]
classes.test <- classes[idx]
classes <- classes[-idx]
```

### 3. Estimate error using cross validation

Choose `lambda` (fraction of lambda.max) and `alpha`, with `alpha = 1` for lasso, `alpha = 0` for group lasso and `alpha` in the range (0,1) for spares group lasso.

Use `msgl::cv` to estimate the error for each lambda in a sequence decreasing from the data derived *lambda max* to `lambda` \* *lambda max*. Lambda max is the lambda at which the first penalized parameter becomes non-zero. A smaller `lambda` will take longer to fit and include more features. The following command will run a 10 fold cross validation for each lambda value in the lambda sequence using 2 parallel units (using the [foreach](https://CRAN.R-project.org/package=foreach) and [doParallel](https://CRAN.R-project.org/package=doParallel) packages.

``` r
cl <- makeCluster(2)
registerDoParallel(cl)

fit.cv <- msgl::cv(x, classes, fold = 10, alpha = 0.5, lambda = 0.1, use_parallel = TRUE)
```

    ## Running msgl 10 fold cross validation (dense design matrix)
    ## 
    ##  Samples:  Features:  Classes:  Groups:  Parameters: 
    ##        155        372         9      372       3.348k

``` r
stopCluster(cl)
```

(for the current version *no progress bar will be shown*)

**Get a summery of the validated models.** We have now cross validated the models corresponding to the lambda values, one model for each lambda value. We may get a summery of this validation by doing:

``` r
fit.cv
```

    ## 
    ## Call:
    ## msgl::cv(x = x, classes = classes, alpha = 0.5, lambda = 0.1, 
    ##     fold = 10, use_parallel = TRUE)
    ## 
    ## Models:
    ## 
    ##  Index:  Lambda:  Features:  Parameters:  Error: 
    ##        1     1.00        1.7         12.5    0.96
    ##       20     0.64       12.3         72.7    0.51
    ##       40     0.40       31.1        165.4    0.28
    ##       60     0.25       43.3        223.9    0.17
    ##       80     0.16       54.3        281.1    0.13
    ##      100     0.10         67        346.8    0.12
    ## 
    ## Best model:
    ## 
    ##  Index:  Lambda:  Features:  Parameters:  Error: 
    ##       79     0.16       53.5        276.9    0.12

Hence, the best model is obtained using lambda index 79 and it has a cross validation error of 0.12. The expected number of selected features is 53.5 and the expected number of parameters is 276.9.

### 4. Fit the final model

Use msgl to fit a final model.

``` r
fit <- msgl::fit(x, classes, alpha = 0.5, lambda = 0.1)
```

    ## 
    ## Running msgl (dense design matrix) 
    ## 
    ##  Samples:  Features:  Classes:  Groups:  Parameters: 
    ##        155        372         9      372       3.348k

**Get a summery of the estimated models**

``` r
fit
```

    ## 
    ## Call:
    ## msgl::fit(x = x, classes = classes, alpha = 0.5, lambda = 0.1)
    ## 
    ## Models:
    ## 
    ##  Index:  Lambda:  Features:  Parameters: 
    ##        1     1.00          2           13
    ##       20     0.64         11           65
    ##       40     0.40         32          171
    ##       60     0.25         43          230
    ##       80     0.16         48          250
    ##      100     0.10         67          345

**Take a look at the estimated models.** As we saw in the previous step the model with index 79 had the best cross validation error, we may take a look at the included features using the command:

``` r
features(fit)[[best_model(fit.cv)]] # Non-zero features in best model
```

    ##  [1] "Intercept"   "let.7c"      "miR.10a"     "miR.17"      "miR.21"     
    ##  [6] "miR.27a"     "miR.34a"     "miR.92a"     "miR.99b"     "miR.122"    
    ## [11] "miR.129.3p"  "miR.130b"    "miR.133a"    "miR.133b"    "miR.135b"   
    ## [16] "miR.138"     "miR.139.5p"  "miR.143"     "miR.147b"    "miR.148a"   
    ## [21] "miR.181a"    "miR.182"     "miR.187"     "miR.191"     "miR.192"    
    ## [26] "miR.196b"    "miR.199a.3p" "miR.203"     "miR.205"     "miR.210"    
    ## [31] "miR.214"     "miR.216a"    "miR.221"     "miR.223"     "miR.224"    
    ## [36] "miR.302b"    "miR.338.3p"  "miR.484"     "miR.505"     "miR.518f"   
    ## [41] "miR.526b"    "miR.532.3p"  "miR.548d.3p" "miR.615.5p"  "miR.625"    
    ## [46] "miR.628.5p"  "miR.885.5p"  "miR.891a"

Hence 48 features are included in the model, this is close to the expected number based on the cross validation estimate.

The sparsity structure of the parameters belonging to these 48 features may be viewed using

``` r
parameters(fit)[[best_model(fit.cv)]]
```

    ## 9 x 48 sparse Matrix of class "lgCMatrix"

    ##    [[ suppressing 48 column names 'Intercept', 'let.7c', 'miR.10a' ... ]]

    ##                                                                          
    ## Breast    | | | . . . . | . | . . | | . . . . | | | | | | | | | | | | | |
    ## CCA       | . | | | | | | | | | . . . . | . . . | | . | . . | . | | . | |
    ## Cirrhosis | . . . | | . . . | | | . . | | | . . . . . . | . | | | . . | .
    ## CRC       | | | | . | | | | | . | . . | . | . | | . | | . | | . | | | | .
    ## EG        | . . | . . . . . | | . | | | | . | | . . | . | | | . | . | . .
    ## HCC       | . | | . | | | . | | | . . | | . . . | . . | . . . | | . . | |
    ## Liver     | | | . | | | | | | . . . . | | | | | | | . | . | | . . | . | .
    ## Pancreas  | | | | | | | | . | | | | . | | . . | . | . | . . . | . . | | |
    ## Squamous  | . . | . . . | . | . | | | . | | . . | | . | | | . | | | | | .
    ##                                          
    ## Breast    | | | . . . | . | . | | | . . .
    ## CCA       | | . | | | | | . | | | | | . |
    ## Cirrhosis | | | . | . . | | | | | | | | |
    ## CRC       | . | . . . . . . . | | . . | |
    ## EG        | . | | | . | | | | | | | . | |
    ## HCC       | | | . | | . . | | . . | . | .
    ## Liver     | . | . | | | . | | . . . . | .
    ## Pancreas  . . . . . | | . . | | . . . | |
    ## Squamous  | | | . | . . . . . . . . . . .

We may also take a look at the estimate parameters (or coefficients)

``` r
coef(fit, best_model(fit.cv))[,1:5] # First 5 non-zero parameters of best model
```

    ## 9 x 5 sparse Matrix of class "dgCMatrix"
    ##            Intercept     let.7c     miR.10a      miR.17      miR.21
    ## Breast     1.9878916 -0.1584741  0.36069273  .           .         
    ## CCA       -5.1225689  .         -0.06873300  0.43649019 -0.16453017
    ## Cirrhosis  2.2972566  .          .           .           0.13574843
    ## CRC       -3.9530078  1.3779491 -1.22697934 -1.51828039  .         
    ## EG         2.6625136  .          .           0.17810433  .         
    ## HCC        0.7163322  .          1.21986449 -0.32891377  .         
    ## Liver      1.7467475 -0.6451481  0.02854112  .           0.20917562
    ## Pancreas   2.2165935 -0.4771551 -0.86238089  1.49733450 -0.02583901
    ## Squamous   3.2212960  .          .          -0.01105621  .

If we count the total number of non-zero parameters in the model we get, in this case 250 which is close to the expected based on the cross validation estimate.

### 6. Use your model for predictions

**Load test data** containing M samples and p features.

``` r
x.test <- # load matrix with test data (of size M x p)
```

Use the final model to predict the classes of the M samples in x.test.

``` r
res <- predict(fit, x.test)

res$classes[,best_model(fit.cv)] # Classes predicted by best model
```

    ##   P-544-ME   P-554-NW   P-559-OI   P-564-MO   P-579-MY   P-590-OU 
    ## "Squamous"    "Liver"       "EG"    "Liver"      "CRC"      "CRC" 
    ##   P-598-PO   Q-199-AB   Q-250-GS   Q-278-DK 
    ##    "Liver"       "EG"      "CCA"       "EG"

``` r
classes.test # True classes
```

    ##  P-544-ME  P-554-NW  P-559-OI  P-564-MO  P-579-MY  P-590-OU  P-598-PO 
    ##    Breast Cirrhosis        EG     Liver       CRC       CRC     Liver 
    ##  Q-199-AB  Q-250-GS  Q-278-DK 
    ##        EG       CCA       CRC 
    ## Levels: Breast CCA Cirrhosis CRC EG HCC Liver Pancreas Squamous

We may also get the estimated probabilities for each of the classes

``` r
res$response[[best_model(fit.cv)]]
```

    ##             P-544-ME    P-554-NW    P-559-OI    P-564-MO    P-579-MY
    ## Breast    0.33627002 0.003666898 0.008523101 0.008627094 0.130026884
    ## CCA       0.13641710 0.025887719 0.060940179 0.033031249 0.052193341
    ## Cirrhosis 0.02247195 0.363252449 0.025993919 0.230733936 0.005976374
    ## CRC       0.04995516 0.003485091 0.086118638 0.008932482 0.722077041
    ## EG        0.03419886 0.049890174 0.646124032 0.043272701 0.017048453
    ## HCC       0.03631994 0.045089311 0.026997086 0.064561217 0.011357562
    ## Liver     0.01538208 0.495049468 0.044679321 0.599770061 0.003780372
    ## Pancreas  0.03196045 0.010330388 0.094168330 0.008467384 0.046820162
    ## Squamous  0.33702443 0.003348502 0.006455393 0.002603876 0.010719812
    ##              P-590-OU    P-598-PO   Q-199-AB   Q-250-GS    Q-278-DK
    ## Breast    0.019390971 0.005849053 0.05118576 0.02535852 0.024274445
    ## CCA       0.026080899 0.020739952 0.15383764 0.58631772 0.190637703
    ## Cirrhosis 0.013410862 0.145627293 0.01485218 0.10756259 0.016026246
    ## CRC       0.724310763 0.007748708 0.14209746 0.04189463 0.065161953
    ## EG        0.114340630 0.051883054 0.47482377 0.04128660 0.553169644
    ## HCC       0.047876502 0.103784661 0.05630570 0.05330133 0.011092432
    ## Liver     0.009547294 0.647171393 0.01621118 0.01737776 0.004748464
    ## Pancreas  0.035241630 0.014386857 0.06862632 0.09484092 0.086934576
    ## Squamous  0.009800449 0.002809030 0.02205999 0.03205991 0.047954538
