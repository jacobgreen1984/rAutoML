# title : gbm_w_cartesianRandom
# author : jacob
# desc : 


# proceed cartesian grid search 
grid <- h2o.grid(
  algorithm = "gbm",
  grid_id = "gbm_w_cartesianRandom1",
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
#cat(">> two-step grid search : cartesian grid search done! \n")

# find optimal range for max_depth
grid_sorted <- h2o.getGrid(grid_id="gbm_w_cartesianRandom1", sort_by="logloss", decreasing=FALSE)
topDepths <- grid_sorted@summary_table$max_depth[1:3]                       
minDepth <- min(as.numeric(topDepths))
maxDepth <- max(as.numeric(topDepths))
#cat(">> the optimal range of max_depth :", minDepth, "~", maxDepth, "\n")

# update max_depth options
RandomGridOptions <- grid_options(algo="gbm")
RandomGridOptions$max_depth <- seq(from=minDepth, to=maxDepth, by=1)

# proceed random grid search 
search_criteria <- list(
  strategy = "RandomDiscrete", 
  max_runtime_secs = 60*60, 
  max_models = 60, 
  seed = 1234
)
grid <- h2o.grid(
  algorithm = "gbm",
  grid_id = "gbm_w_cartesianRandom2",
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
  hyper_params = RandomGridOptions,
  search_criteria = search_criteria
)
#cat(">> two-step grid search : random grid search done! \n")


grid_sorted <- h2o.getGrid(grid_id="gbm_w_cartesianRandom2", sort_by="logloss", decreasing=FALSE)
gbm_w_cartesianRandom <- h2o.getModel(grid_sorted@model_ids[[1]])


cat(">> gbm_w_cartesianRandom train auc :", h2o.performance(gbm_w_cartesianRandom, train=TRUE)@metrics$AUC)
cat(">> gbm_w_cartesianRandom valid auc :", h2o.performance(gbm_w_cartesianRandom, valid=TRUE)@metrics$AUC)
cat(">> gbm_w_cartesianRandom test  auc :", h2o.performance(gbm_w_cartesianRandom, newdata=test_hex)@metrics$AUC)

