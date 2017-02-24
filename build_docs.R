package_name <- function(path) {
    out <- c(read.dcf(list.files(path, pattern="DESCRIPTION",
        recursive=TRUE, full.names=TRUE), "Package"))
    return(out)
}

package_version <- function(path) {
    out <- c(read.dcf(list.files(path, pattern="DESCRIPTION",
        recursive=TRUE, full.names=TRUE), "Version"))
    return(out)
}

get_git_branch <- function(path) {

  old_path <- getwd()
  setwd(path)

  git_branch_cmd <- "git  branch | grep '^\\*' | cut -d' ' -f2"

  if(Sys.info()['sysname'] == "Windows") {
    res <- system("cmd.exe", input = git_branch_cmd, intern = TRUE)
    res <- res[5] # this is a bit shaky
  } else {
    res <- system2(git_branch_cmd)
  }

  setwd(old_path)

  return( res )
}

build_install_local <- function(path) {

  pkg <- package_name(path)
  ver <- package_version(path)

  build_command <- paste("R CMD build ", path)
  system(build_command)

  build_name <- paste(pkg, "_", ver, ".tar.gz", sep="")
  install_command <- paste("R CMD INSTALL ", build_name)
  system(install_command)
}

## Get script path
script.path <- getSrcDirectory(function(x) {x})

## Update git branch in DESCRIPTION
branch <- get_git_branch(script.path)
print(branch)

x_dcf <- read.dcf(file = file.path(script.path,"DESCRIPTION"))
x_dcf[1,"GitHubRepo"] <- branch
write.dcf(x_dcf, file = file.path(script.path,"DESCRIPTION"))

## Roxygenise
library("roxygen2")

script.path <- getSrcDirectory(function(x) {x})

pkg <- package_name(script.path)

roxygenise(script.path)
print(warnings())

build_install_local(script.path)

## Build vignettes and README
pandoc.installed <- system('pandoc -v')==0

if(pandoc.installed) {

  vignettes.path <- file.path(script.path, "vignettes")
  vignettes.files <- list.files(vignettes.path, pattern="*.Rmd")

  for(file in vignettes.files) {

    input_file <- file.path(vignettes.path, file)

    print(getwd())

    rmarkdown::render(
      input = input_file,
      output_format = rmarkdown::md_document(variant = "markdown_github"),
      output_dir = script.path
    )

  }

} else {
  warning("Not building vignettes")
}
