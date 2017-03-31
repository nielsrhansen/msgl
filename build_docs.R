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
    res <- system(git_branch_cmd, intern = TRUE)
  }

  setwd(old_path)

  return( res )
}

build_install_local <- function(path) {

  pkg <- package_name(path)
  ver <- package_version(path)

  build_command <- paste("R CMD build --no-build-vignettes", path)
  system(build_command)

  build_name <- paste(pkg, "_", ver, ".tar.gz", sep="")
  install_command <- paste("R CMD INSTALL", build_name)
  system(install_command)
}

## Get script path
script.path <- getSrcDirectory(function(x) {x})

print(script.path)

## Update git branch in DESCRIPTION
branch <- get_git_branch(script.path)
print(branch)

# update branch and date in DESCRIPTION
x_dcf <- read.dcf(file = file.path(script.path,"DESCRIPTION"))
  x_dcf[1,"GitHubRepo"] <- branch
  x_dcf[1,"Date"] <- as.character(Sys.Date())
write.dcf(x_dcf, file = file.path(script.path,"DESCRIPTION"))


## Roxygenise
library("roxygen2")

pkg <- package_name(script.path)

print(pkg)

roxygenise(script.path)
print(warnings())

build_install_local(script.path)

## Build vignettes and README
pandoc.installed <- system('pandoc -v')==0

if(pandoc.installed) {

  vignettes.path <- file.path(script.path, "vignettes")
  vignettes.files <- list.files(vignettes.path, pattern="*.Rmd")

  old_path <- getwd()
  setwd(script.path)

  for(file in vignettes.files) {

    input_file <- file.path(vignettes.path, file)

    rmarkdown::render(
      input = input_file,
      output_format = rmarkdown::md_document(variant = "markdown_github")
    )

  }

  setwd(old_path)

  # Move generated files to pkg root
  files_to_move <- list.files(vignettes.path)
  files_to_move <- files_to_move[ ! files_to_move %in% vignettes.files ]

  for(file in files_to_move) {

    from <- file.path(vignettes.path, file)
    to <- file.path(script.path, file)

    unlink(to, recursive = TRUE)
    file.rename(from, to)
  }

} else {
  warning("Not building vignettes")
}
