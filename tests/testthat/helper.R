expect_different = function(x, y) {
  expect_false(identical(x, y))
}


#' Expect grepl error: similar to `expect_error` and friends but adds some
#' polars options to avoid duplicating calls
#'
#' @param expr an R expression to test
#' @param expected_err one or several string patterns passed to grepl
#' @param do_not_repeat_call bool, prevent error-handler to add call to err msg
#' useful for grepping the same error message, without grep-patterns becomes
#' included in the error message. Latter leads to false positive outcomes.
#' @param ... args passed to expect_identical which will run if grepl fails
#' @details expr must raise an error and expected_err pattern must match
#' against the error text with grepl()
#' @keywords internal
#' @return invisble NULL
#'
#' @examples
#' # passes as "carrot" is in "orange and carrot"
#' expect_grepl_error(stop("orange and carrot"),"carrot")
#' expect_grepl_error(stop("orange and carrot"),c("carrot","orange"))

expect_grepl_error = function(expr, expected_err = NULL, do_not_repeat_call =TRUE, ...) {

  #turn of including call in err msg
  if(do_not_repeat_call) {
    old_options = pl$set_polars_options(do_not_repeat_call=TRUE)
  }

  #capture err msg
  err = NULL
  err = tryCatch(expr, error = function(e) {as.character(e)})

  #restore previous options state
  if(do_not_repeat_call) do.call(pl$set_polars_options, old_options)

  #check if error message contains pattern
  founds = sapply(expected_err,\(x) isTRUE(grepl(x,err)[1]))

  if(!all(founds)) {
    #... if not use testthat to point out the difference
    expect_identical(err, expected_err[which(!founds)[1]],...)
  }

  invisible(err)
}
