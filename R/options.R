
# R runtime options
##all polars sessions options saved to here
polars_optenv = new.env(parent = emptyenv())
polars_optreq = list() #all requirement functions put in here

# WRITE ALL DEFINED OPTIONS BELOW HERE



#' @rdname polars_options
#' @name strictly_immutable
#' @aliases strictly_immutable
#' @param strictly_immutable bool, default = TRUE, keep polars strictly immutable.
#' Polars/arrow is in general pro "immutable objects". However pypolars API has some minor exceptions.
#' All settable property elements of classes are mutable.
#' Why?, I guess python just do not have strong stance on immutability.
#' R strongly suggests immutable objects, so why not make polars strictly immutable where little performance costs?
#' However, if to mimic pypolars as much as possible, set this to FALSE.
#'
polars_optenv$strictly_immutable = TRUE #set default value
polars_optreq$strictly_immutable = list( #set requirement functions of default value
  is_bool = function (x) {
    is.logical(x) && length(x)==1 && !is.na(x)
  }
)

#' @rdname polars_options
#' @name named_exprs
#' @aliases named_exprs
#' @param named_exprs bool, default = FALSE,
#' allow named exprs in e.g. select, with_columns, groupby, join.
#' a named expresion will be extended with $alias(name)
#' wildcards or expression producing multiple are problematic due to name collision
#' the related option in py-polars is currently called 'pl.Config.with_columns_kwargs'
#' and only allow named exprs in with_columns (or potentially any method derived there of)
#'
#' @examples
#' #rename columns by naming expression, experimental requires option named_exprs = TRUE
#' pl$set_polars_options(named_exprs = TRUE)
#' pl$DataFrame(iris)$with_columns(
#'   pl$col("Sepal.Length")$abs(), #not named expr will keep name "Sepal.Length"
#'   SW_add_2 = (pl$col("Sepal.Width")+2)
#' )
polars_optenv$named_exprs = FALSE #set default value
polars_optreq$named_exprs = list( #set requirement functions of default value
  is_bool = function (x) {
    is.logical(x) && length(x)==1 && !is.na(x)
  }
)


#' @rdname polars_options
#' @name no_messages
#' @aliases no_messages
#' @details who likes polars package messages? use this option to turn them off.
#' @param no_messages bool, default = FALSE,
#' turn of messages
polars_optenv$no_messages = FALSE #set default value
polars_optreq$no_messages = list( #set requirement functions of default value
  is_bool = function (x) {
    is.logical(x) && length(x)==1 && !is.na(x)
  }
)

#' @rdname polars_options
#' @name do_not_repeat_call
#' @details do not print the call causing the error in error messages
#' @param do_not_repeat_call bool, default = FALSE,
#' turn of messages
polars_optenv$do_not_repeat_call = FALSE #set default value
polars_optreq$do_not_repeat_call = list( #set requirement functions of default value
  is_bool = function (x) {
    is.logical(x) && length(x)==1 && !is.na(x)
  }
)


## END OF DEFINED OPTIONS


#' polars options
#' @description  get, set, reset polars options
#' @rdname polars_options
#' @name get_polars_options
#' @aliases  polars_options
#'
#'
#' @return current settings as list
#' @details modifing list takes no effect, pass it to pl$set_polars_options
#' get/set/resest interact with internal env `polars:::polars_optenv`
#'
#'
#' @examples  pl$get_polars_options()
pl$get_polars_options = function() {
  as.list(polars_optenv)
}


#' @param ... any options to modify
#'
#' @param return_replaced_options return previous state of modified options
#' Convenient for temporarily swapping of options during testing.
#'
#' @rdname polars_options
#' @name set_polars_options
#' @return current settings as list
#' @details setting an options may be rejected if not passing opt_requirements
#' @examples
#' pl$set_polars_options(strictly_immutable = FALSE)
#' pl$get_polars_options()
#'
#'
#' #setting strictly_immutable = 42 will be rejected as
#' tryCatch(
#'   pl$set_polars_options(strictly_immutable = 42),
#'   error= function(e) print(e)
#' )
#'
pl$set_polars_options = function(
  ...,
  return_replaced_options = TRUE
) {

  #check opts
  opts = list2(...)
  if(is.null(names(opts)) || !all(nzchar(names(opts)))) stopf("all options passed must be named")
  unknown_opts = setdiff(names(opts),names(polars_optenv))
  if(length(unknown_opts)) {
    stopf(paste("unknown option(s) was passed:",paste(unknown_opts,collapse=", ")))
  }

  #update options
  replaced_opts_list = list()
  for(i in names(opts)) {
    opt_requirements = polars_optreq[[i]]
    stopifnot(
      !is.null(opt_requirements),
      is.list(opt_requirements),
      all(sapply(opt_requirements,is.function)),
      all(nzchar(names(opt_requirements)))
    )

    for (j in  names(opt_requirements)) {
      opt_check = opt_requirements[[j]]
      opt_value = opts[[i]]
      opt_result = opt_check(opt_value)
      if(!isTRUE(opt_result)) {
        stopf(paste(
          "option:",i," must satisfy requirement named",j,
          "with function\n", paste(capture.output(print(opt_check)),collapse="\n")
        ))
      }
    }

    replaced_opts_list[[i]] = polars_optenv[[i]]
    polars_optenv[[i]] = opts[[i]]
  }

  if(return_replaced_options) {
    return(replaced_opts_list)
  }

  #return current option set invisible
  invisible(pl$get_polars_options())
}



polars_opts_defaults = as.list(polars_optenv)
#' @rdname polars_options
#' @name reset_polars_options
#' @examples
#' #reset options like this
#' pl$reset_polars_options()
pl$reset_polars_options = function() {
  rm(list=ls(envir = polars_optenv),envir = polars_optenv)
  for(i in names(polars_opts_defaults)) {
    polars_optenv[[i]] = polars_opts_defaults[[i]]
  }
  invisible(NULL)
}


#' @rdname polars_options
#' @name reset_polars_options
#' @return list named by options of requirement function input must satisfy
#' @examples
#' #use get_polars_opt_requirements() to requirements
#' pl$get_polars_opt_requirements()
pl$get_polars_opt_requirements = function() {
  polars_optreq
}


#' internal keeping of state at runtime
#' @name polars_runtime_flags
#' @description This environment is used internally for the package to remember
#' what has been going on. Currently only used to throw one-time warnings()
runtime_state = new.env(parent = emptyenv())




