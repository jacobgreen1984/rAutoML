# title : gbm_w_cartesian
# author : jacob
# desc : 


# gbm_w_cartesian 
grid <- h2o.grid(
  algorithm = "gbm",
  grid_id = "gbm_w_cartesian",
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

grid_sorted <- h2o.getGrid(grid_id="gbm_w_cartesian", sort_by="logloss", decreasing=FALSE)
gbm_w_cartesian <- h2o.getModel(grid_sorted@model_ids[[1]])


cat(">> gbm_w_cartesian train auc :", h2o.performance(gbm_w_cartesian, train=TRUE)@metrics$AUC)
cat(">> gbm_w_cartesian valid auc :", h2o.performance(gbm_w_cartesian, valid=TRUE)@metrics$AUC)
cat(">> gbm_w_cartesian test  auc :", h2o.performance(gbm_w_cartesian, newdata=test_hex)@metrics$AUC)

