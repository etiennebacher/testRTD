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

* I had to manually add a `@usage` tag in the roxygen docs for each function. I don't know if this specific to this example or this will be the case also for polars.


### Requirements

#### `mkdocs-material`

Install it: https://squidfunk.github.io/mkdocs-material/getting-started/#installation

#### Names of .Rd files

To create subsections for each general "class" in "Reference" and to put each Rd file in the good class subsection, the script uses the names of Rd files.

More specifically, it looks for all Rd files that end with `-class` (here `Series-class.Rd` and `DataFrame-class.Rd`) and defines them as subsections. Then, all files starting with `Series-` (except `Series-class.Rd`) will be put in this subsection. Same for files starting with `DataFrame-`.

The remaining files are put in the subsection "Other".

Therefore, it is essential to correctly name the Rd files, which is done with the `@name` parameter in the roxygen doc of the R files.


