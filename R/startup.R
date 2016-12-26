.onAttach <- function(libname, pkgname) {

	c.config <- msgl.c.config()

  if(c.config$timing) packageStartupMessage("msgl: runtime profiling is on")

	if(c.config$debugging) packageStartupMessage("msgl: Compiled with debugging on -- this may slow down runtime")

}
