get_script_path <- function() {
    cmd.args <- commandArgs()
    m <- regexpr("(?<=^--file=).+", cmd.args, perl=TRUE)

    script.dir <- dirname(regmatches(cmd.args, m))

    if(length(script.dir) == 0) stop("can't determine script dir: please call the script with Rscript")
    if(length(script.dir) > 1) stop("can't determine script dir: more than one '--file' argument detected")

    return(script.dir)
}

run_test <- function(file, path) {

  script <- file.path(path, file)
  run_command <- paste("Rscript", script)
  system(run_command)
}

path <- file.path(getwd(), get_script_path())

test.path <- file.path(path, "tests")
test.files <- list.files(test.path)

setwd(test.path)
for(file in test.files)
 run_test(file, test.path)
