\name{NEWS}
\title{News for Package 'msgl'}

\section{Changes in msgl version 2.3.5 (2016-12-28)}{
\itemize{
  \item API changes:
  \itemize{
    \item msgl.lambda.seq deprecated use msgl::lambda
    \item msgl deprecated use msgl::fit
    \item msgl.cv deprecated use msgl::cv
    \item msgl.subsampling deprecated use msgl::subsampling
  }
  \item fit, cv and subsampling supports relative lambda
  \item Code cleanup, bug fixes and refactoring
  \item Removed non-generic default sample weights from cv -- this may imply that the lambda sequence needs adjustment to reach the same results.
}
}
\section{Changes in msgl version 2.3.0 (2016-09-28)}{
  \itemize{
  \item added quick-start vignette
  \item added functions for extracting number of nonzero features and parameters (\code{feature_stat} and \code{parameter_stat})
  \item seed argument removed
  \item minor fixes and updates
  \item Better handling of R memory protection (fewer PROTECT calls)
	\item subsampling uses foreach and doParallel (showing a progressbar is no longer supported for subsampling and cross validation)
	\item subsampling now supports different lambda sequences for each subsample
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
