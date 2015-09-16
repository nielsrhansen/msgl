//R interface

extern "C" {

SEXP r_pkg_c_config();

}

SEXP pkg_c_config() {

	//Debuging
	bool debug_on = false;
#ifdef SGL_DEBUG
	debug_on = true;
#endif

	//omp support
	bool omp_supp = false;
#ifdef SGL_OPENMP_SUPP
	omp_supp = true;
#endif

	//profiling
	bool timing = false;
#ifdef SGL_TIMING
	timing = true;
#endif

	//Runtime checking for numerical problems
	bool runtime_checks = false;
#ifdef SGL_RUNTIME_CHECKS
	runtime_checks = true;
#endif

	//Check dimension of input objects
	bool dim_checks = false;
#ifdef SGL_DIM_CHECKS
	dim_checks = true;
#endif

	//Converges checks
	bool conv_check = false;
#ifdef SGL_CONVERGENCE_CHECK
			conv_check = true;
#endif

	//Exception handling
	bool catch_exceptions = false;
#ifdef SGL_CATCH_EXCEPTIONS
	catch_exceptions = true;
#endif

	rList res;
	res.attach(rObject(debug_on), "debugging");
	res.attach(rObject(omp_supp), "omp.supported");
	res.attach(rObject(runtime_checks), "runtime.checks");
	res.attach(rObject(dim_checks), "dim.checks");
	res.attach(rObject(conv_check), "convergence.checks");
	res.attach(rObject(catch_exceptions), "catch.exceptions");

	return rObject(res);
}

SEXP r_pkg_c_config() {

	try {

		return pkg_c_config();

		//Catch unhandled exceptions

	} catch (std::exception & e) {

		if (e.what() != NULL) {
			report_error(e.what());
		}

		else {
			report_error("Unknown error");
		}

	} catch (...) {
		report_error("Unknown error");
	}

	return R_NilValue; //Avoid compiler warnings
}
