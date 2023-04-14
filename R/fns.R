#' @name DataFrame
#' @export

DataFrame <- new.env(parent = emptyenv())

#' @param self Unused
#'
#' @param name Unused
#'
#' @name `[[.DataFrame`
#' @keywords DataFrame
#' @export

`$.DataFrame` <- function (self, name) {
  func <- DataFrame[[name]]
  environment(func) <- environment()
  func
}

#' @name `[[.DataFrame`
#' @keywords DataFrame
#' @export

`[[.DataFrame` <- `$.DataFrame`




#' Create a new Polars DataFrame
#' @name DataFrame$new
#' @export
#' @examples
#' DataFrame$new()

DataFrame$new <- function() {
  print("new")
}

#' Extract one or several columns
#' @name DataFrame$get_column
#' @export
#' @examples
#' DataFrame$new()$get_column("a")
#' DataFrame$new()$get_columns("a", "b")

DataFrame$get_column <- function(...) {
  print("get_column")
}

#' @export
#' @name DataFrame$get_columns

DataFrame$get_columns <- function(...) {
  print("get_columns")
}

#' Get data type
#' @name datatype
#' @export
#' @examples
#' DataFrame$new()$dtypes

DataFrame$dtypes <- function(...) {
  print("dtypes")
}

#' Create new DataFrame
#' @name DataFrame
#'
#' @return DataFrame
#' @keywords DataFrame_new

pl$DataFrame = function() {
  print("foo")
}
