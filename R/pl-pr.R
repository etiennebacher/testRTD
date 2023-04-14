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
.pr$Series     = function(foo)
.pr$DataFrame  = function(foo)
.pr$GroupBy    = NULL # derived from DataFrame in R, has no rust calls
.pr$LazyFrame  = function(foo)
.pr$LazyGroupBy= function(foo)
.pr$PolarsBackgroundHandle = function(foo)
.pr$DataType   = function(foo)
.pr$DataTypeVector = function(foo)
.pr$RField      = function(foo)
.pr$Expr       = function(foo)
.pr$ProtoExprArray = function(foo)
.pr$When           = function(foo)
.pr$WhenThen       = function(foo)
.pr$WhenThenThen   = function(foo)
.pr$VecDataFrame = function(foo)
.pr$RNullValues = function(foo)


# TODO remove export



#' Give a class method property behavior
#' @description Internal function, see use in source
#' @param f a function
#' @param setter bool, if true a property method can be modified by user
#' @return function subclassed into c("property","function") or c("setter","property","function")
method_as_property = function(f, setter=FALSE) {
  class(f) = if(setter) {
    c("setter","property","function")
  } else {
    c("property","function")
  }
  f
}


#' @title The complete polars public API.
#' @description `pl`-object is a environment of all public functions and class constructors.
#' Public functions are not exported as a normal package as it would be huge namespace
#' collision with base:: and other functions. All object-methods are accessed with object$method()
#' via the new class functions.
#'
#' Having all functions in an namespace is similar to the rust- and python- polars api.
#' @rdname pl
#' @name pl
#' @aliases pl
#' @keywords api
#' @details If someone do not particularly like the letter combination `pl`, they are free to
#' bind the environment to another variable name as `simon_says = pl` or even do `attach(pl)`
#'
#' @export
#' @examples
#' #how to use polars via `pl`
#' pl$col("colname")$sum() / pl$lit(42L)  #expression ~ chain-method / literal-expression
#'
#' #pl inventory
#' polars:::print_env(pl,"polars public functions")
#'
#' #all accessible classes and their public methods
#' polars:::print_env(
#'   polars:::pl_pub_class_env,
#'   "polars public class methods, access via object$method()"
#' )
pl = new.env(parent=emptyenv())


pl_class_names = sort(
  c("LazyFrame","Series","LazyGroupBy","DataType","Expr","DataFrame", "PolarsBackgroundHandle",
    "When", "WhenThen", "WhenThenThen"
  )
) #TODO discover all public class automaticly


