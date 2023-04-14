#' extendr methods into pure functions
#'
#' @param env environment object output from extendr-wrappers.R classes
#' @keywords internals
#' @description self is a global of extendr wrapper methods
#' this function copies the function into a new environment and
#' modify formals to have a self argument
#'
#' @return env of pure function calls to rust
#'
extendr_method_to_pure_functions = function(env) {
  as.environment(lapply(env,function(f) {
    if(!is.function(f)) return(f)
    if("self" %in% codetools::findGlobals(f)) {
      formals(f) <- c(alist(self=),formals(f))
    }
    f
  }))
}


#' @title polars-API: private calls to rust-polars
#' @description `.pr`
#' Original extendr bindings converted into pure functions
#' @aliases  .pr
#' @keywords api_private
#' @export
#' @examples
#' #.pr$DataFrame$print() is an external function where self is passed as arg
#' polars:::.pr$DataFrame$print(self = pl$DataFrame(iris))
#' @examples
#' polars:::print_env(.pr,".pr the collection of private method calls to rust-polars")
.pr            = new.env(parent=emptyenv())
.pr$GroupBy    = NULL # derived from DataFrame in R, has no rust calls

