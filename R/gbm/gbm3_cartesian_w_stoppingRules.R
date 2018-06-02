# title : gbm3_cartesian_w_stoppingRules
# author : jacob
# desc :


grid <- h2o.grid(
  algorithm = "gbm",
  grid_id = "gbm3_cartesian",
  x = x,
  y = y,
  training_frame = train_hex,
  validation_frame = valid_hex,
  seed = 1234,
  stopping_rounds = stopping_rules$stopping_rounds,
  stopping_metric = stopping_rules$stopping_metric,
  stopping_tolerance = stopping_rules$stopping_tolerance,
  score_each_iteration = stopping_rules$score_each_iteration,
  ntrees = stopping_rules$ntrees,
  hyper_params = grid_options(algo="gbm")[1],
  search_criteria = list(strategy = "Cartesian")
)

grid_sorted <- h2o.getGrid(grid_id="gbm3_cartesian", sort_by="logloss", decreasing=FALSE)
bayesGridSearch <- h2o.getModel(grid_sorted@model_ids[[1]])

gbm3_cartesian_w_stoppingRules <- h2o.gbm(
  x = x,
  y = y,
  seed = 1234,
  training_frame = train_hex,
  validation_frame = valid_hex,
  max_depth = bayesGridSearch@allparameters$max_depth,
  learn_rate = bayesGridSearch@allparameters$learn_rate,
  sample_rate = bayesGridSearch@allparameters$sample_rate,
  col_sample_rate = bayesGridSearch@allparameters$col_sample_rate,
  stopping_rounds = stopping_rules$stopping_rounds,
  stopping_metric = stopping_rules$stopping_metric,
  stopping_tolerance = stopping_rules$stopping_tolerance,
  score_each_iteration = stopping_rules$score_each_iteration,
  ntrees = stopping_rules$ntrees,
  model_id = "gbm3"
)

cat(">> gbm3 done! \n")

