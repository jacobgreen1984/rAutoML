# title : gbm_w_random
# author : jacob
# desc : 


# gbm_w_random 
search_criteria <- list(
  strategy = "RandomDiscrete", 
  max_runtime_secs = 60*60, 
  max_models = 60, 
  seed = 1234
)

grid <- h2o.grid(
  algorithm = "gbm",
  grid_id = "gbm_w_random",
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
  search_criteria = search_criteria
)

grid_sorted <- h2o.getGrid(grid_id="gbm_w_random", sort_by="logloss", decreasing=FALSE)
gbm_w_random <- h2o.getModel(grid_sorted@model_ids[[1]])


cat(">> gbm_w_random train auc :", h2o.performance(gbm_w_random, train=TRUE)@metrics$AUC)
cat(">> gbm_w_random valid auc :", h2o.performance(gbm_w_random, valid=TRUE)@metrics$AUC)
cat(">> gbm_w_random test  auc :", h2o.performance(gbm_w_random, newdata=test_hex)@metrics$AUC)


