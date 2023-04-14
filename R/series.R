
#' Create new Series
#'
#' Found in api as pl$Series named Series_constructor internally
#'
#' @usage
#' Series(x, name)
#'
#' @name Series-class
#'
#' @param x any vector
#' @param name string
#'
#' @export
#' @examples
#' pl$Series(1:4)

Series <- new.env(parent = emptyenv())

#' Make a deep copy of a new Polars Series
#'
#' @usage
#' <Series>$clone(...)
#'
#' @param ... Not used
#'
#' @name Series-clone
#' @export

Series$clone <- function(...) print("clone")

#' Sleep (?) in a new Polars Series
#'
#' @usage
#' <Series>$sleep(millis)
#'
#' @param millis Duration of sleep
#'
#' @name Series-sleep
#' @export

Series$sleep <- function(millis) print("sleep")

#' Panic in a new Polars Series
#'
#' @usage
#' <Series>$panic()
#'
#' @name Series-panic
#' @export

Series$panic <- function() print("panic")
