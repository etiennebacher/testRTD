# Store Time in R

## Arguments

- `x`: an integer or double vector of n epochs since midnight OR a char vector of char times passed to as.POSIXct converted to seconds.
- `tu`: timeunit either "s","ms","us","ns"
- `fmt`: a format string passed to as.POSIXct format via ...

## Returns

a PTime vector either double or integer, with class "PTime" and attribute "tu" being either "s","ms","us" or "ns"

Store Time in R

## Details

PTime should probably be replaced with package nanotime or similar.

base R is missing encoding of Time since midnight "s" "ms", "us" and "ns". The latter "ns" is the standard for the polars Time type.

Use PTime to convert R doubles and integers and use as input to polars functions which needs a time.

Loosely inspired by data.table::ITime which is i32 only. PTime must support polars native timeunit is nanoseconds. The R double(float64) can imitate a i64 ns with full precision within the full range of 24 hours.

PTime does not have a time zone and always prints the time as is no matter local machine time zone.

An essential difference between R and polars is R prints POSIXct/lt without a timezone in local time. Polars prints Datetime without a timezone label as is (GMT). For POSIXct/lt taged with a timexone(tzone) and Datetime with a timezone(tz) the behavior is the same conversion is intuitive.

It appears behavior of R timezones is subject to change a bit in R 4.3.0, see polars unit test test-expr_datetime.R/"pl$date_range Date lazy/eager".

## Examples

```r
#make PTime in all time units
pl$PTime(runif(5)*3600*24*1E0, tu = "s")
pl$PTime(runif(5)*3600*24*1E3, tu = "ms")
pl$PTime(runif(5)*3600*24*1E6, tu = "us")
pl$PTime(runif(5)*3600*24*1E9, tu = "ns")
pl$PTime("23:59:59")


pl$Series(pl$PTime(runif(5)*3600*24*1E0, tu = "s"))
pl$lit(pl$PTime("23:59:59"))$lit_to_s()

pl$lit(pl$PTime("23:59:59"))$to_r()
```