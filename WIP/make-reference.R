library(altdoc)
library(yaml)

if (fs::dir_exists(here::here("docs/docs/reference"))) {
  fs::dir_delete(here::here("docs/docs/reference"))
}
fs::dir_create(here::here("docs/docs/reference"))

get_general_classes <- function() {
  rd_files <- list.files("man", pattern = "-class\\.Rd")
  gsub("-class\\.Rd$", "", rd_files)
}

make_doc_hierarchy <- function() {
  general_classes <- get_general_classes()

  all_rd <- list.files("man", pattern = "\\.Rd")

  hierarchy <- list()
  for (i in general_classes) {
    components <- list.files("man", pattern = paste0("^", i))
    all_rd <<- all_rd[-which(components %in% all_rd)]
    components <- components[-which(grepl("-class\\.Rd$", components))]
    components <- gsub("\\.Rd", "\\.md", components)
    components <- paste0("reference/", components)
    hierarchy[[i]] <- sort(components)
  }

  remaining <- grep(paste0("^(", paste(general_classes, collapse = "|"), ")"),
                    all_rd, invert = TRUE)
  remaining <- all_rd[remaining]
  remaining <- gsub("\\.Rd", "\\.md", remaining)
  remaining <- paste0("reference/", remaining)

  hierarchy[["Other"]] <-remaining

  hierarchy
}

convert_to_md <- function() {
  rd_files <- list.files("man", pattern = "\\.Rd")
  for (i in rd_files) {
    Rd2md::Rd2markdown(paste0("man/", i), paste0("docs/docs/reference/", gsub("\\.Rd", "\\.md", i)))
  }
}

convert_hierarchy_to_yml <- function() {
  hierarchy <- make_doc_hierarchy()
  final_hierarchy <- list(Reference = hierarchy)
  out <- as.yaml(final_hierarchy, indent = 2,
                 indent.mapping.sequence = TRUE,
                 omap = TRUE)
  out <- gsub("!!omap", "", out)
  cat(out)

  cat("\n^^^^^^^^^^^^^^ Copy this in `docs/mkdocs.yml`")
}

convert_to_md()
convert_hierarchy_to_yml()

