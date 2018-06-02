# title : gbm_w_bayesian
# author : jacob
# desc : https://a-ghorbani.github.io/2016/11/24/data-science-with-h2o


# h2o_bayes
h2o_bayes <- function(max_depth, learn_rate, sample_rate,col_sample_rate){
  require(rBayesianOptimization)
  require(h2o)  
  gbm <- h2o.gbm(  
    x                    = x,
    y                    = y,
    training_frame       = train_hex,
    validation_frame     = valid_hex,
    max_depth            = max_depth,
    learn_rate           = learn_rate,
    sample_rate          = sample_rate,
    col_sample_rate      = col_sample_rate,
    seed                 = 1234,
    stopping_rounds      = stopping_rules$stopping_rounds,
    stopping_metric      = stopping_rules$stopping_metric,
    stopping_tolerance   = stopping_rules$stopping_tolerance,
    score_each_iteration = stopping_rules$score_each_iteration,
    ntrees               = stopping_rules$ntrees
  )
  score <- h2o.auc(gbm, valid = T)
  list(Score = score, Pred  = 0)
}


# BayesGridOptions
BayesGridOptions <- grid_options(algo="gbm")
BayesGridOptions <- lapply(BayesGridOptions,range)
#print(BayesGridOptions)


# gbm_w_bayesian
BayesianSearchRst <- BayesianOptimization(
  FUN = h2o_bayes,
  bounds = BayesGridOptions,
  init_points = 30,  
  n_iter = 30,
  acq = "ucb",
  kappa = 2.576,
  eps = 0.0,
  verbose = TRUE
)


# gbm_w_bayesian
gbm_w_bayesian <- h2o.gbm(
  x = x,
  y = y,
  seed = 1234,
  training_frame = train_hex,
  validation_frame = valid_hex,
  max_depth = BayesianSearchRst$Best_Par["max_depth"],
  learn_rate = BayesianSearchRst$Best_Par["learn_rate"],
  sample_rate = BayesianSearchRst$Best_Par["sample_rate"],
  col_sample_rate = BayesianSearchRst$Best_Par["col_sample_rate"],
  stopping_rounds = stopping_rules$stopping_rounds,
  stopping_metric = stopping_rules$stopping_metric,
  stopping_tolerance = stopping_rules$stopping_tolerance,
  score_each_iteration = stopping_rules$score_each_iteration,
  ntrees = stopping_rules$ntrees
)


cat(">> gbm_w_bayesian train auc :", h2o.performance(gbm_w_bayesian, train=TRUE)@metrics$AUC)
cat(">> gbm_w_bayesian valid auc :", h2o.performance(gbm_w_bayesian, valid=TRUE)@metrics$AUC)
cat(">> gbm_w_bayesian test  auc :", h2o.performance(gbm_w_bayesian, newdata=test_hex)@metrics$AUC)

