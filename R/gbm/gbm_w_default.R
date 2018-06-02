# title : gbm_w_default
# author : jacob
# desc : 


# gbm_w_default 
gbm_w_default <- h2o.gbm(  
  x = x,
  y = y,
  training_frame = train_hex,
  validation_frame = valid_hex,
  seed = 1234
)

cat(">> gbm_w_default train auc :", h2o.performance(gbm_w_default, train=TRUE)@metrics$AUC)
cat(">> gbm_w_default valid auc :", h2o.performance(gbm_w_default, valid=TRUE)@metrics$AUC)
cat(">> gbm_w_default test  auc :", h2o.performance(gbm_w_default, newdata=test_hex)@metrics$AUC)