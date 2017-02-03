get_script_path <- function() {
    cmd.args <- commandArgs()
    m <- regexpr("(?<=^--file=).+", cmd.args, perl=TRUE)

    script.dir <- dirname(regmatches(cmd.args, m))

    if(length(script.dir) == 0) stop("can't determine script dir: please call the script with Rscript")
    if(length(script.dir) > 1) stop("can't determine script dir: more than one '--file' argument detected")

    return(script.dir)
}

get_git_branch <- function(path) {
  git_branch_cmd <- paste("cd", path, ";",  "git  branch | grep '^\\*' | cut -d' ' -f2")
  system(git_branch_cmd, intern = TRUE)
}

package_name <- function(path) {
    out <- c(read.dcf(list.files(path, pattern="DESCRIPTION",
        recursive=TRUE, full.names=TRUE), "Package"))
    return(out)
}

build_install_local <- function(pkg, path, build_vignettes = FALSE) {
  ver <- packageVersion(pkg, lib.loc = path)

  build_flags <- if(build_vignettes) "" else "--no-build-vignettes"
  build_command <- paste("R CMD build ", build_flags, file.path(path, pkg))
  system(build_command)

  build_name <- paste(pkg, "_", ver, ".tar.gz", sep="")
  install_command <- paste("R CMD INSTALL ", build_name)
  system(install_command)
}

if( ! "roxygen2" %in% rownames(installed.packages())) {
  install.packages("roxygen2", repos = "https://cloud.r-project.org")
}

library("roxygen2")

script.path <- get_script_path()
path <- file.path(getwd(), script.path)
pkg <- package_name(path)

roxygenise(path)
print(warnings())

# build vignettes
pandoc.installed <- system('pandoc -v')==0

if(pandoc.installed) {

  build_install_local(pkg, file.path(path, ".."), build_vignettes = FALSE)

  vignettes.path <- file.path(script.path, "vignettes")
  vignettes.files <- list.files(vignettes.path, pattern="*.Rmd")

  branch <- get_git_branch(script.path)
  print(branch)

  for(file in vignettes.files) {

    rmarkdown::render(
      input = file.path(vignettes.path, file),
      output_format = rmarkdown::md_document(variant = "markdown_github"),
      output_dir = script.path,
      params = list(branch = branch)
    )
  }

} else {
  warning("Not building vignettes")
}

# install
build_install_local(pkg, file.path(path, ".."), build_vignettes = pandoc.installed)
