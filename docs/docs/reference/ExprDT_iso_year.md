# Iso-Year

## Format

function

## Returns

Expr of iso_year as Int32

Extract ISO year from underlying Date representation. Applies to Date and Datetime columns. Returns the year number in the ISO standard. This may not correspond with the calendar year.

## Examples

```r
df = pl$DataFrame(
  date = pl$date_range(
    as.Date("2020-12-25"),
    as.Date("2021-1-05"),
    interval = "1d",
    time_zone = "GMT"
  )
)
df$with_columns(
  pl$col("date")$dt$year()$alias("year"),
  pl$col("date")$dt$iso_year()$alias("iso_year")
)
```