# sort column by order of others

## Format

a method

```r
Expr_sort_by(by, reverse = FALSE)
```

## Arguments

- `by`: one expression or list expressions and/or strings(interpreted as column names)
- `reverse`: single bool to boolean vector, any is_TRUE will give reverse sorting of that column

## Returns

Expr

Sort this column by the ordering of another column, or multiple other columns.

## Details

In projection/ selection context the whole column is sorted. If used in a groupby context, the groups are sorted.

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

## Examples

```r
df = pl$DataFrame(list(
  group = c("a","a","a","b","b","b"),
  value1 = c(98,1,3,2,99,100),
  value2 = c("d","f","b","e","c","a")
))

# by one column/expression
df$select(
  pl$col("group")$sort_by("value1")
)

# by two columns/expressions
df$select(
  pl$col("group")$sort_by(list("value2",pl$col("value1")), reverse =c(TRUE,FALSE))
)


# by some expression
df$select(
  pl$col("group")$sort_by(pl$col("value1")$sort(reverse=TRUE))
)

#quite similar usecase as R function `order()`
l = list(
  ab = c(rep("a",6),rep("b",6)),
  v4 = rep(1:4, 3),
  v3 = rep(1:3, 4),
  v2 = rep(1:2,6),
  v1 = 1:12
)
df = pl$DataFrame(l)


#examples of order versus sort_by
all.equal(
  df$select(
    pl$col("ab")$sort_by("v4")$alias("ab4"),
    pl$col("ab")$sort_by("v3")$alias("ab3"),
    pl$col("ab")$sort_by("v2")$alias("ab2"),
    pl$col("ab")$sort_by("v1")$alias("ab1"),
    pl$col("ab")$sort_by(list("v3",pl$col("v1")),reverse=c(FALSE,TRUE))$alias("ab13FT"),
    pl$col("ab")$sort_by(list("v3",pl$col("v1")),reverse=TRUE)$alias("ab13T")
  )$to_list(),
  list(
    ab4 = l$ab[order(l$v4)],
    ab3 = l$ab[order(l$v3)],
    ab2 = l$ab[order(l$v2)],
    ab1 = l$ab[order(l$v1)],
    ab13FT= l$ab[order(l$v3,rev(l$v1))],
    ab13T = l$ab[order(l$v3,l$v1,decreasing= TRUE)]
  )
)
```