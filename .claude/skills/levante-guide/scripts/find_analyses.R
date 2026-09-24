# Index the `levante:` frontmatter of levante-analysis notebooks
# (schema: levante-analysis/ANALYSIS_METADATA.md).
#
# Usage: Rscript --vanilla find_analyses.R [filters] [--full] [--repo PATH]
#   --task X      task_id or short name (vocab, math, tom, ...)
#   --dataset X   substring of a dataset name (e.g. bogota, mpieva)
#   --status X    draft | reviewed | superseded
#   --text X      regex matched against title, summary, and findings
#   --full        also print data sources, dependencies, and findings
#   --repo PATH   levante-analysis checkout (default: sibling of levante-data-meta)
# Filters combine with AND. `--dataset` also matches notebooks with datasets: all.

suppressPackageStartupMessages(library(yaml))
`%||%` <- function(a, b) if (is.null(a)) b else a

args <- commandArgs(trailingOnly = TRUE)
opt <- function(name) {
  i <- match(paste0("--", name), args)
  if (is.na(i)) NULL else args[i + 1]
}
full <- "--full" %in% args

# Default repo: <LEVANTE root>/levante-analysis, located from this script's
# real path (the skill may be symlinked into ~/.claude/skills).
script <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE))
meta_repo <- normalizePath(file.path(dirname(normalizePath(script)), "..", "..", "..", ".."))
repo <- opt("repo") %||% file.path(dirname(meta_repo), "levante-analysis")
if (!dir.exists(repo)) stop("levante-analysis not found at ", repo, "; pass --repo PATH")

short <- c(hf = "hearts-and-flowers", mg = "memory-game", memory = "memory-game",
           sds = "same-different-selection", matrix = "matrix-reasoning",
           mrot = "mental-rotation", math = "egma-math", tom = "theory-of-mind")
task <- opt("task")
if (!is.null(task) && task %in% names(short)) task <- short[[task]]

files <- c(Sys.glob(file.path(repo, c("[01]*.qmd", "tasks/*.qmd", "tasks/*/*.qmd", "reports/*.qmd"))))

read_header <- function(f) {
  lines <- readLines(f, warn = FALSE, encoding = "UTF-8")
  if (length(lines) == 0 || lines[1] != "---") return(NULL)
  end <- which(lines[-1] == "---")[1] + 1
  yaml.load(paste(lines[2:(end - 1)], collapse = "\n"))
}

no_meta <- character()
hits <- list()
for (f in files) {
  rel <- sub(paste0(repo, "/"), "", f, fixed = TRUE)
  h <- read_header(f)
  m <- h$levante
  if (is.null(m)) { no_meta <- c(no_meta, rel); next }
  ds <- unlist(m$datasets)
  if (!is.null(task) && !(task %in% unlist(m$task_ids))) next
  if (!is.null(opt("dataset")) && !identical(ds, "all") &&
      !any(grepl(opt("dataset"), ds, fixed = TRUE))) next
  if (!is.null(opt("status")) && m$status != opt("status")) next
  if (!is.null(opt("text")) &&
      !grepl(opt("text"), paste(h$title, m$summary, paste(unlist(m$findings), collapse = " ")),
             ignore.case = TRUE)) next
  hits[[rel]] <- list(h = h, m = m, ds = ds)
}
# With --task, list task-specific notebooks before broad multi-task chapters.
if (!is.null(task)) hits <- hits[order(sapply(hits, \(x) length(x$m$task_ids)))]

for (rel in names(hits)) {
  h <- hits[[rel]]$h; m <- hits[[rel]]$m; ds <- hits[[rel]]$ds
  sup <- if (!is.null(m$superseded_by)) paste0(" -> ", m$superseded_by) else ""
  cat(sprintf("%s  [%s%s, last_run %s]\n", rel, m$status, sup, m$last_run))
  if (!is.null(h$title)) cat("  title:    ", h$title, "\n")
  cat("  summary:  ", m$summary, "\n")
  cat("  tasks:    ", if (length(m$task_ids)) paste(unlist(m$task_ids), collapse = ", ") else "(none)", "\n")
  cat("  datasets: ", if (length(ds)) paste(ds, collapse = ", ") else "(none)", "\n")
  if (full) {
    for (d in m$data)
      cat("  data:     ", d$source, if (!is.null(d$version)) paste0("@", d$version), paste0("(", d$table, ")"), "\n")
    if (length(m$depends_on)) cat("  depends:  ", paste(unlist(m$depends_on), collapse = ", "), "\n")
    for (x in m$findings) cat("  - ", x, "\n")
  }
  cat("\n")
}
cat(length(hits), "matching notebook(s) in", repo, "\n")
if (length(no_meta)) cat("No `levante:` metadata (not searchable):", paste(no_meta, collapse = ", "), "\n")
