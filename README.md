## Documentation for `polars` (R implementation): demo

(Can also be used in other projects, do whatever you want with this.)

**NOTE:** the only objective of this repo is to see how documentation for projects that have a lot of methods can be automatically generated. I did not check anything in terms of R CMD check.

### Demo

https://etiennebacher.github.io/testRTD/site/

### Reproduce

1. Clone the repo
2. Run `source("WIP/make-reference.R")`
  * this will convert all Rd files to .md and will copy them in "docs/docs/reference"
  * it will show the yaml code to paste in "docs/mkdocs.yml"
3. Run `altdoc::preview()` 

### Challenges

* Vignettes will need to be converted and moved automatically from Rmd format (in "vignettes" folder) to md format somewhere in "docs/docs".

* I don't understand the code structure of `polars` enough to know if this simple example can be adapted

* Can't use pkgdown CI



### Requirements

To create subsections for each general "class" in "Reference" and to put each Rd file in the good class subsection, the script uses the names of Rd files.

More specifically, it looks for all Rd files that end with `-class` (here `Series-class.Rd` and `DataFrame-class.Rd`) and defines them as subsections. Then, all files starting with `Series-` (except `Series-class.Rd`) will be put in this subsection. Same for files starting with `DataFrame-`.

The remaning files are put in the subsection "Other".

Therefore, it is essential to correctly name the Rd files, which is done with the `@name` parameter in the roxygen doc of the R files.


