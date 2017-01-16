
create_test_data <- function() {

  data(SimData)

  classes <- LETTERS[1:10][classes]

  data <- list()
  data$X <- x
  data$classes <- classes

  return( data )
}
