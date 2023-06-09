#' New Expr referring to all columns
#' @name all
#' @description
#' Not to mix up with `Expr_object$all()` which is a 'reduce Boolean columns by AND' method.
#'
#' @keywords Expr_new
#'
#' @return Boolean literal
#'
#' @details  last `all()` in example is this Expr method, the first `pl$all()` refers
#' to "all-columns" and is an expression constructor
#'
#' @examples
#' pl$DataFrame(list(all=c(TRUE,TRUE),some=c(TRUE,FALSE)))$select(pl$all()$all())
pl$all = function(name=NULL) {

  if(is.null(name)) return(.pr$Expr$col("*"))

  stopf("not implemented")
  #TODO implement input list of Expr as in:
  #https://github.com/pola-rs/polars/blob/589f36432de6e95e81d9715a77d6fe78360512e5/py-polars/polars/internals/lazy_functions.py#L1095
}


#' Start Expression with a column
#' @name col
#' @description
#'Return an expression representing a column in a DataFrame.
#' @param name
#' - a single column by a string
#' - all columns by using a wildcard `"*"`
#' - multiple columns as vector of strings
#' - column by regular expression if the regex starts with `^` and ends with `$`
#' e.g. pl$DataFrame(iris)$select(pl$col(c("^Sepal.*$")))
#' - a single DataType or an R list of DataTypes, select any column of any such DataType
#' - Series of utf8 strings abiding to above options
#'
#' @return Column Exprression
#'
#' @keywords Expr_new
#' @examples
#'
#' df = pl$DataFrame(list(foo=1, bar=2L,foobar="3"))
#'
#' #a single column by a string
#' df$select(pl$col("foo"))
#'
#' #all columns by wildcard
#' df$select(pl$col("*"))
#' df$select(pl$all())
#'
#' #multiple columns as vector of strings
#' df$select(pl$col(c("foo","bar")))
#'
#' #column by regular expression if the regex starts with `^` and ends with `$`
#' df$select(pl$col("^foo.*$"))
#'
#' #a single DataType
#' df$select(pl$col(pl$dtypes$Float64))
#'
#' # ... or an R list of DataTypes, select any column of any such DataType
#' df$select(pl$col(list(pl$dtypes$Float64, pl$dtypes$Utf8)))
#'
#' # from Series of names
#' df$select(pl$col(pl$Series(c("bar","foobar"))))
pl$col = function(name="") {

  #preconvert Series into char name(s)

  if(inherits(name,"Series")) name = name$to_r_vector()

  if(is_string(name)) return(.pr$Expr$col(name))
  if(is.character(name)) {
    if(any(sapply(name, \(x) {
      isTRUE(substr(x,1,1)=="^") && isTRUE(substr(x,nchar(x),nchar(x))=="$")
    }))) {
      warning("cannot use regex syntax when param name, has length > 1")
    }
    return(.pr$Expr$cols(name))
  }
  if(inherits(name, "RPolarsDataType"))return(.pr$Expr$dtype_cols(construct_DataTypeVector(list(name))))
  if(is.list(name)) {
    if(all(sapply(name, inherits,"RPolarsDataType"))) {
      return(.pr$Expr$dtype_cols(construct_DataTypeVector(name)))
    } else {
      stopf("all elements of list must be a RPolarsDataType")
    }
  }
  #TODO implement series, DataType
  stopf("not supported implement input")
}

#' an element in 'eval'-expr
#' @name element
#' @description Alias for an element in evaluated in an `eval` expression.
#' @keywords Expr
#' @return Expr
#' @aliases element
#' @examples
#' pl$lit(1:5)$cumulative_eval(pl$element()$first()-pl$element()$last() ** 2)$to_r()
pl$element = function() pl$col("")



#TODO contribute polars, python pl.sum(list) states uses lambda, however it is folds expressions in rust
#docs should reflect that

#' sum across expressions / literals / Series
#' @description  syntactic sugar for starting a expression with sum
#' @name sum
#' @param ...  is a:
#' If one arg:
#'  - Series or Expr, same as `column$sum()`
#'  - string, same as `pl$col(column)$sum()`
#'  - numeric, same as `pl$lit(column)$sum()`
#'  - list of strings(column names) or exprressions to add up as expr1 + expr2 + expr3 + ...
#'
#' If several args, then wrapped in a list and handled as above.
#' @return Expr
#' @keywords Expr_new
#' @examples
#' #column as string
#' pl$DataFrame(iris)$select(pl$sum("Petal.Width"))
#'
#' #column as Expr (prefer pl$col("Petal.Width")$sum())
#' pl$DataFrame(iris)$select(pl$sum(pl$col("Petal.Width")))
#'
#' #column as numeric
#' pl$DataFrame()$select(pl$sum(1:5))
#'
#' #column as list
#' pl$DataFrame(a=1:2,b=3:4,c=5:6)$with_column(pl$sum(list("a","c")))
#' pl$DataFrame(a=1:2,b=3:4,c=5:6)$with_column(pl$sum(list("a","c", 42L)))
#'
#' #three eqivalent lines
#' pl$DataFrame(a=1:2,b=3:4,c=5:6)$with_column(pl$sum(list("a","c", pl$sum(list("a","b","c")))))
#' pl$DataFrame(a=1:2,b=3:4,c=5:6)$with_column(pl$sum(list(pl$col("a")+pl$col("b"),"c")))
#' pl$DataFrame(a=1:2,b=3:4,c=5:6)$with_column(pl$sum(list("*")))
pl$sum = function(...) {
  column = list2(...)
  if (length(column)==1L) column = column[[1L]]
  if (inherits(column, "Series") || inherits(column, "Expr")) return(column$sum())
  if (is_string(column)) return(pl$col(column)$sum())
  if (is.numeric(column)) return(pl$lit(column)$sum())
  if (is.list(column)) {
    pra = do.call(construct_ProtoExprArray,column)
    return(sum_exprs(pra))
  }
  stopf("pl$sum: this input is not supported")
}


#' min across expressions / literals / Series
#' @description Folds the expressions from left to right, keeping the first non-null value.
#' @name min
#' @param ...  is a:
#' If one arg:
#'  - Series or Expr, same as `column$sum()`
#'  - string, same as `pl$col(column)$sum()`
#'  - numeric, same as `pl$lit(column)$sum()`
#'  - list of strings(column names) or exprressions to add up as expr1 + expr2 + expr3 + ...
#'
#' If several args, then wrapped in a list and handled as above.
#' @return Expr
#' @keywords Expr_new
#' @examples
#' df = pl$DataFrame(
#'   a = NA_real_,
#'   b = c(2:1,NA_real_,NA_real_),
#'   c = c(1:3,NA_real_),
#'   d = c(1:2,NA_real_,-Inf)
#' )
#' #use min to get first non Null value for each row, otherwise insert 99.9
#' df$with_column(
#'   pl$min("a", "b", "c", 99.9)$alias("d")
#' )
#'
pl$min = function(...) {
  column = list2(...)
  if (length(column)==1L) column = column[[1L]]
  if (inherits(column, "Series") || inherits(column, "Expr")) return(column$min())
  if (is_string(column)) return(pl$col(column)$min())
  if (is.numeric(column)) return(pl$lit(column)$min())
  if (is.list(column)) {
    pra = do.call(construct_ProtoExprArray,column)
    return(min_exprs(pra))
  }
  stopf("pl$min: this input is not supported")
}





#' max across expressions / literals / Series
#' @description Folds the expressions from left to right, keeping the first non-null value.
#' @name max
#' @param ...  is a:
#' If one arg:
#'  - Series or Expr, same as `column$sum()`
#'  - string, same as `pl$col(column)$sum()`
#'  - numeric, same as `pl$lit(column)$sum()`
#'  - list of strings(column names) or exprressions to add up as expr1 + expr2 + expr3 + ...
#'
#' If several args, then wrapped in a list and handled as above.
#' @return Expr
#' @keywords Expr_new
#' @examples
#' df = pl$DataFrame(
#'   a = NA_real_,
#'   b = c(1:2,NA_real_,NA_real_),
#'   c = c(1:3,NA_real_)
#' )
#' #use coalesce to get first non Null value for each row, otherwise insert 99.9
#' df$with_column(
#'   pl$coalesce("a", "b", "c", 99.9)$alias("d")
#' )
#'
pl$max = function(...) {
  column = list2(...)
  if (length(column)==1L) column = column[[1L]]
  if (inherits(column, "Series") || inherits(column, "Expr")) return(column$max())
  if (is_string(column)) return(pl$col(column)$max())
  if (is.numeric(column)) return(pl$lit(column)$max())
  if (is.list(column)) {
    pra = do.call(construct_ProtoExprArray,column)
    return(max_exprs(pra))
  }
  stopf("pl$max: this input is not supported")
}




#' Coalesce
#' @description Folds the expressions from left to right, keeping the first non-null value.
#' @name coalesce
#' @param ...  is a:
#' If one arg:
#'  - Series or Expr, same as `column$sum()`
#'  - string, same as `pl$col(column)$sum()`
#'  - numeric, same as `pl$lit(column)$sum()`
#'  - list of strings(column names) or exprressions to add up as expr1 + expr2 + expr3 + ...
#'
#' If several args, then wrapped in a list and handled as above.
#' @return Expr
#' @keywords Expr_new
#' @examples
#' df = pl$DataFrame(
#'   a = NA_real_,
#'   b = c(1:2,NA_real_,NA_real_),
#'   c = c(1:3,NA_real_)
#' )
#' #use coalesce to get first non Null value for each row, otherwise insert 99.9
#' df$with_column(
#'   pl$coalesce("a", "b", "c", 99.9)$alias("d")
#' )
#'
pl$coalesce = function(...) {
  column = list2(...)
  pra = do.call(construct_ProtoExprArray,column)
  coalesce_exprs(pra)
}




pl$std = function(column, ddof = 1) {
  if (inherits(column, "Series") || inherits(column, "Expr")) return(column$std(ddof))
  if (is_string(column)) return(pl$col(column)$std(ddof))
  if (is.numeric(column)) return(pl$lit(column)$std(ddof))
  stopf("pl$std: this input is not supported")
}

pl$var = function(column, ddof = 1) {
  if (inherits(column, "Series") || inherits(column, "Expr")) return(column$var(ddof))
  if (is_string(column)) return(pl$col(column)$var(ddof))
  if (is.numeric(column)) return(pl$lit(column)$var(ddof))
  stopf("pl$var: this input is not supported")
}




#' Concat the arrays in a Series dtype List in linear time.
#' @description Folds the expressions from left to right, keeping the first non-null value.
#' @name coalesce
#' @param exprs list of Expr or Series or strings or a mix, or a char vector
#' @return Expr
#'
#' @keywords Expr_new
#'
#' @examples
#' #Create lagged columns and collect them into a list. This mimics a rolling window.
#' df = pl$DataFrame(A = c(1,2,9,2,13))
#' df$with_columns(lapply(
#'   0:2,
#'   \(i) pl$col("A")$shift(i)$alias(paste0("A_lag_",i))
#' ))$select(
#'   pl$concat_list(lapply(2:0,\(i) pl$col(paste0("A_lag_",i))))$alias(
#'   "A_rolling"
#'  )
#' )
#'
#' #concat Expr a Series and an R obejct
#' pl$concat_list(list(
#'   pl$lit(1:5),
#'   pl$Series(5:1),
#'   rep(0L,5)
#' ))$alias("alice")$lit_to_s()
#'
pl$concat_list = function(exprs) {
  l_expr = lapply(as.list(exprs), wrap_e)
  pra = do.call(construct_ProtoExprArray, l_expr)
  concat_lst(pra)
}


#' struct
#' @name struct
#' @aliases struct
#' @description Collect several columns into a Series of dtype Struct.
#' @param exprs Columns/Expressions to collect into a Struct.
#' @param eager Evaluate immediately.
#' @param schema Optional schema named list that explicitly defines the struct field dtypes.
#' Each name must match a column name wrapped in the struct. Can only be used to cast some or all
#' dtypes, not to change the names. NULL means to include keep columns into the struct by their
#' current DataType. If a column is not included in the schema it is removed from the final struct.
#'
#' @details pl$struct creates Expr or Series of DataType Struct()
#' pl$Struct creates the DataType Struct()
#' In polars a schema is a named list of DataTypes. #' A schema describes e.g. a DataFrame.
#' More formally schemas consist of Fields.
#' A Field is an object describing the name and DataType of a column/Series, but same same.
#' A struct is a DataFrame wrapped into a Series, the DataType is Struct, and each
#' sub-datatype within are Fields.
#' In a dynamic language schema and a Struct (the DataType) are quite the same, except
#' schemas describe DataFrame and Struct's describe some Series.
#'
#' @return Eager=FALSE: Expr of Series with dtype Struct | Eager=TRUE: Series with dtype Struct
#'
#' @examples
#' #isolated expression to wrap all columns in a struct aliased 'my_struct'
#' pl$struct(pl$all())$alias("my_struct")
#'
#' #wrap all column into on column/Series
#' df = pl$DataFrame(
#'   int = 1:2,
#'   str = c("a", "b"),
#'   bool = c(TRUE, NA),
#'   list = list(1:2, 3L)
#' )$select(
#'   pl$struct(pl$all())$alias("my_struct")
#' )
#'
#' print(df)
#' print(df$schema) #returns a schema, a named list containing one element a Struct named my_struct
#'
#' # wrap two columns in a struct and provide a schema to set all or some DataTypes by name
#' e1 = pl$struct(
#'   pl$col(c("int","str")),
#'   schema = list(int=pl$Int64, str=pl$Utf8)
#' )$alias("my_struct")
#' # same result as e.g. wrapping the columns in a struct and casting afterwards
#' e2 = pl$struct(
#'   list(pl$col("int"),pl$col("str"))
#' )$cast(
#'   pl$Struct(int=pl$Int64,str=pl$Utf8)
#' )$alias("my_struct")
#'
#' df = pl$DataFrame(
#'   int = 1:2,
#'   str = c("a", "b"),
#'   bool = c(TRUE, NA),
#'   list = list(1:2, 3L)
#' )
#'
#' #verify equality in R
#' identical(df$select(e1)$to_list(),df$select(e2)$to_list())
#'
#' df$select(e2)
#' df$select(e2)$as_data_frame()
pl$struct = function(
  exprs, # list of exprs, str or Series or Expr or Series,
  eager = FALSE,
  schema = NULL
) {

  #convert any non expr to expr and catch error in a result
  as_struct(wrap_elist_result(exprs, str_to_lit = FALSE)) |>
    and_then(\(struct_expr) {#if no errors continue struct_expr
      #cast expression
      if(!is.null(schema)) {
        struct_expr = struct_expr$cast(pl$Struct(schema))
      }
      if(!is_bool(eager)) return(Err("arg [eager] is not a bool"))
      if(eager) {
        result(pl$select(struct_expr)$to_series())
      }else {
        Ok(struct_expr)
      }
    }) |> unwrap(#raise any error with context
      "in pl$struct:"
    )
}



