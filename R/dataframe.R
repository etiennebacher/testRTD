
#' @title The complete polars public API.
#' @rdname pl
#' @name pl
#' @export

pl = new.env(parent = emptyenv())

#' General class for a Polars DataFrame
#' @name DataFrame-class
#' @export

DataFrame <- new.env(parent = emptyenv())

#' @name DataFrame-double-brackets
#' @export

`$.DataFrame` <- function (self, name) {
  func <- DataFrame[[name]]
  environment(func) <- environment()
  func
}

#' @title Subset a Polars DataFrame
#' @name DataFrame-double-brackets
#' @export

`[[.DataFrame` <- `$.DataFrame`


#' Create a new Polars DataFrame
#' @name DataFrame-new
#' @export
#' @examples
#' DataFrame$new()

DataFrame$new <- function() {
  print("new")
}

#' Extract columns from a Polars DataFrame
#'
#' @usage
#' <DataFrame>$get_column(...)
#' <DataFrame>$get_columns(...)
#'
#' @param ... Not used
#'
#' @name DataFrame-get_column
#' @export
#' @examples
#' DataFrame$new()$get_column("a")
#' DataFrame$new()$get_columns("a", "b")

DataFrame$get_column <- function(...) {
  print("get_column")
}

#' @export
#' @name DataFrame-get_column

DataFrame$get_columns <- function(...) {
  print("get_columns")
}


#' Get the type of variables in a Polars DataFrame
#'
#' @usage
#' <DataFrame>$dtypes(...)
#'
#' @param ... Not used
#'
#' @name DataFrame-dtypes
#' @export
#' @examples
#' DataFrame$new()$dtypes()

DataFrame$dtypes <- function(...) {
  print("dtypes")
}

