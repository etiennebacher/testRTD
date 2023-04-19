# append (default immutable)

```r
Series_append(other, immutable = TRUE)
```

## Arguments

- `other`: Series to append
- `immutable`: bool should append be immutable, default TRUE as mutable operations should be avoided in plain R API's.

## Returns

Series

append two Series, see details for mutability

## Details

if immutable = FLASE, the Series object will not behave as immutable. This mean appending to this Series will affect any variable pointing to this memory location. This will break normal scoping rules of R. Polars-clones are cheap. Mutable operations are likely never needed in any sense.

## Examples

```r
#default immutable behaviour, s_imut and s_imut_copy stay the same
s_imut = pl$Series(1:3)
s_imut_copy = s_imut
s_new = s_imut$append(pl$Series(1:3))
identical(s_imut$to_r_vector(),s_imut_copy$to_r_vector())

#pypolars-like mutable behaviour,s_mut_copy become the same as s_new
s_mut = pl$Series(1:3)
s_mut_copy = s_mut
 #must deactivate this to allow to use immutable=FALSE
pl$set_polars_options(strictly_immutable = FALSE)
s_new = s_mut$append(pl$Series(1:3),immutable= FALSE)
identical(s_new$to_r_vector(),s_mut_copy$to_r_vector())
```