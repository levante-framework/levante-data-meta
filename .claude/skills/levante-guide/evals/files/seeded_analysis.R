library(levante); library(tidyverse); library(mirt)
scores <- get_scores("levante_data_latest:e9pf")
trials <- get_trials("levante_data_latest:e9pf", version = "v1_2")

# overall ability: average across all tasks per child
ability <- scores |> group_by(user_id, site) |> summarise(g = mean(score, na.rm = TRUE))

# which country does best?
ability |> group_by(site) |> summarise(mean_g = mean(g)) |> arrange(desc(mean_g))

# growth: T2 - T1 per child per task
growth <- scores |> group_by(user_id, task_id) |> arrange(age) |>
  summarise(delta = last(score) - first(score), .groups = "drop")

# rescore ToM ourselves
mod <- readRDS("tom_model.rds")
wide <- trials |> filter(task_id == "theory-of-mind") |>
  select(run_id, item_uid, correct) |> pivot_wider(names_from = item_uid, values_from = correct)
th <- fscores(mod, response.pattern = as.matrix(wide[,-1]))
