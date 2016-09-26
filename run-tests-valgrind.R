get_script_path <- function() {
    cmd.args <- commandArgs()
    m <- regexpr("(?<=^--file=).+", cmd.args, perl=TRUE)

    script.dir <- dirname(regmatches(cmd.args, m))

    if(length(script.dir) == 0) stop("can't determine script dir: please call the script with Rscript")
    if(length(script.dir) > 1) stop("can't determine script dir: more than one '--file' argument detected")

    return(script.dir)
}

package_name <- function(path) {
    out <- c(read.dcf(list.files(path, pattern="DESCRIPTION",
        recursive=TRUE, full.names=TRUE), "Package"))
    return(out)
}

build_install_local <- function(pkg, path) {
  ver <- packageVersion(pkg, lib.loc = path)

  build_command <- paste("R CMD build ", file.path(path, pkg))
  system(build_command)

  build_name <- paste(pkg, "_", ver, ".tar.gz", sep="")
  install_command <- paste("R CMD INSTALL ", build_name)
  system(install_command)
}

run_test_valgrind <- function(file, path) {

  script <- file.path(path, file)
  run_command <- paste("R -d \"valgrind --leak-check=full --show-reachable=yes\" -f", script)
  system(run_command)
}

library("roxygen2")

path <- file.path(getwd(), get_script_path())
pkg <- package_name(path)

roxygenise(path)
print(warnings())

test.path <- file.path(path, "tests")
test.files <- list.files(test.path)

for(file in test.files)
 run_test_valgrind(file, test.path)
