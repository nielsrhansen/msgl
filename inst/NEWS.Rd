\name{NEWS}
\title{News for Package 'msgl'}
\newcommand{\cpkg}{\href{http://CRAN.R-project.org/package=#1}{\pkg{#1}}}

\section{Changes in msgl version 2.2.1 (2016-??-??)}{
  \itemize{
  \item added quick-start vignette
  \item minor fixes and updates
}
}


\section{Changes in msgl version 2.2.0 (2015-09-16)}{
\itemize{
  \itemize{
  \item Improved reliability and usability:
  \itemize{
  	\item prefix printing
    \item correct handling of non penalized parameters when computing lambda.max (fit non penalized parameters before computing critical lambdas)
    \item increased speed when optimizing with a high number of groups/classes (> 100) 
    \item some improvements on error reporting and argument validation
   }
   
   \item Fixes :
     \itemize{
        \item fixed bug related to grouping 
        \item fixed seval minor bugs
        \item fixed startup messages 
     }
  }
}
}

\section{Changes in msgl version 2.0.122.0 (2014-03-22)}{
  \itemize{
  \item Improved usability:
  \itemize{
    \item the new function \code{Err} computes error rates directly
    \item the new functions \code{coef}, \code{features} and \code{parameters} extract nonzero coefficients, features and parameters respectively.
    \item the package is now more informative. A \code{print.msgl} function has been added and by default a progress bar (using package \cpkg{RcppProgress}) is shown when the algorithm is running.
    \item it is now possible to fit models without intercepts by setting \code{intercept = FALSE}.
    \item the \code{seed} argument in \code{msgl.cv} is deprecated, use \code{set.seed} instead.    
   }
   \item The package now uses the generic sparse group lasso optimizer \cpkg{sglOptim}.
   \item A new versioning scheme is used. (package version a.b.c.d is interpreted as follows: a - primary
    version, b - major updates and fixes, c - source revision as corresponding
    to R-Forge, d - minor fixes made only to the CRAN branch of the source)
    
  }
}

