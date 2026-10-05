# Canonical task_code -> display label + category mapping, shared across
# LEVANTE repos. Source it via a path relative to the LEVANTE root, e.g.
#   source(here("..", "levante-data-meta", "task_info.R"))
#
# Labels and categories are title-cased and the factor levels are kept in the
# order below, which is the intended display order (tasks grouped by category).

task_info <- dplyr::tribble(
  ~task_code , ~task_label              , ~task_category,
  "hf"       , "hearts & flowers"       , "executive function",
  "sds"      , "same & different"       , "executive function",
  "mg"       , "memory"                 , "executive function",
  "math"     , "math"                   , "math",
  "matrix"   , "pattern matching"       , "reasoning",
  "mrot"     , "shape rotation"         , "spatial cognition",
  "trog"     , "sentence understanding" , "language",
  "vocab"    , "vocabulary"             , "language",
  "tom"      , "stories"                , "social cognition",
  "pa"       , "language sounds"        , "reading",
  "sre"      , "sentence reading"       , "reading",
  "swr"      , "word reading"           , "reading",
) |>
  dplyr::mutate(task_label = task_label |> stringr::str_to_title() |> forcats::fct_inorder(),
                task_category = task_category |> stringr::str_to_title() |> forcats::fct_inorder())
