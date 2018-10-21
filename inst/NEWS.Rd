\name{NEWS}
\title{News for Package 'msgl'}

\section{Changes in msgl version 2.3.7 (2018-10-18)}{
\itemize{
  \item Original author and previous maintainer, Martin Vincent, has stopped development. This version is released by a new maintainer. Changes from version 2.3.6 are only to comply to CRAN policies.
}
}


\section{Changes in msgl version 2.3.6 (2017-03-03)}{
\itemize{
  \item Bug fixes
}
}

\section{Changes in msgl version 2.3.5 (2016-12-28)}{
\itemize{
  \item API changes:
    msgl.lambda.seq deprecated use msgl::lambda,
    msgl deprecated use msgl::fit,
    msgl.cv deprecated use msgl::cv,
    msgl.subsampling deprecated use msgl::subsampling
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
  	\item Improved reliability and usability:
  		prefix printing;
    	correct handling of non penalized parameters when computing lambda.max (fit non penalized parameters before computing critical lambdas);
    	increased speed when optimizing with a high number of groups/classes (> 100);
    	some improvements on error reporting and argument validation
     \item fixed bug related to grouping
     \item fixed seval minor bugs
     \item fixed startup messages
  	}
}
