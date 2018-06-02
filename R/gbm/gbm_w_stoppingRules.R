# title : gbm_w_stoppingRules
# author : jacob
# desc : 


# gbm_w_stoppingRules 
gbm_w_stoppingRules <- h2o.gbm(  
  x = x,
  y = y,
  training_frame = train_hex,
  validation_frame = valid_hex,
  seed = 1234,
  stopping_rounds = stopping_rules$stopping_rounds,
  stopping_metric = stopping_rules$stopping_metric,
  stopping_tolerance = stopping_rules$stopping_tolerance,
  score_each_iteration = stopping_rules$score_each_iteration,
  ntrees = stopping_rules$ntrees
)


cat(">> gbm_w_stoppingRules train auc :", h2o.performance(gbm_w_stoppingRules, train=TRUE)@metrics$AUC)
cat(">> gbm_w_stoppingRules valid auc :", h2o.performance(gbm_w_stoppingRules, valid=TRUE)@metrics$AUC)
cat(">> gbm_w_stoppingRules test  auc :", h2o.performance(gbm_w_stoppingRules, newdata=test_hex)@metrics$AUC)