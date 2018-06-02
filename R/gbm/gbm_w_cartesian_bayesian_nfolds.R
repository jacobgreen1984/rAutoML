# title : gbm_w_cartesian_bayesian_nfolds
# author : jacob
# desc : https://a-ghorbani.github.io/2016/11/24/data-science-with-h2o


# h2o_bayes_nfolds ----
h2o_bayes_nfolds <- function(max_depth, learn_rate, sample_rate, col_sample_rate){
  require(rBayesianOptimization)
  require(h2o)
  gbm <- h2o.gbm(  
    x = x,
    y = y,
    seed = 1234,
    training_frame = h2o.rbind(train_hex,valid_hex),
    nfolds = 3,
    max_depth = max_depth,
    learn_rate = learn_rate,
    sample_rate = sample_rate,
    col_sample_rate = col_sample_rate,
    stopping_rounds = stopping_rules$stopping_rounds,
    stopping_metric = stopping_rules$stopping_metric,
    stopping_tolerance = stopping_rules$stopping_tolerance,
    score_each_iteration = stopping_rules$score_each_iteration,
    ntrees = stopping_rules$ntrees
  )
  score <- h2o.auc(gbm, xval = T)
  list(Score = score, Pred  = 0)
}


# proceed cartesian grid search ----
grid <- h2o.grid(
  algorithm = "gbm",
  grid_id = "gbm_w_cartesian_bayesian_nfolds",
  x = x,
  y = y,
  training_frame = h2o.rbind(train_hex, valid_hex),
  nfolds = 3,
  seed = 1234,
  stopping_rounds = stopping_rules$stopping_rounds,
  stopping_metric = stopping_rules$stopping_metric,
  stopping_tolerance = stopping_rules$stopping_tolerance,
  score_each_iteration = stopping_rules$score_each_iteration,
  ntrees = stopping_rules$ntrees,
  hyper_params = grid_options(algo="gbm")[1],
  search_criteria = list(strategy = "Cartesian")
)


# find optimal range for max_depth ----
grid_sorted <- h2o.getGrid(grid_id="gbm_w_cartesian_bayesian_nfolds", sort_by="logloss", decreasing=FALSE)
topDepths <- grid_sorted@summary_table$max_depth[1:3]                       
minDepth <- min(as.numeric(topDepths))
maxDepth <- max(as.numeric(topDepths))
#cat(">> the optimal range of max_depth :", minDepth, "~", maxDepth, "\n")


# update max_depth options ----
BayesGridOptions <- grid_options(algo="gbm")
BayesGridOptions$max_depth <- as.integer(seq(from=minDepth, to=maxDepth, by=1))
BayesGridOptions <- lapply(BayesGridOptions,range)
#print(BayesGridOptions)


# BayesianSearchRst ----
set.seed(1234)
BayesianSearchRst <- BayesianOptimization(
  FUN = h2o_bayes_nfolds,
  bounds = BayesGridOptions,
  init_points = 30,  
  n_iter = 30,
  acq = "ucb",
  kappa = 2.576,
  eps = 0,
  verbose = TRUE
)


# gbm_w_cartesian_bayesian_nfolds ----
gbm_w_cartesian_bayesian_nfolds <- h2o.gbm(
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


cat(">> gbm_w_cartesian_bayesian_nfolds train auc :", h2o.performance(gbm_w_cartesian_bayesian_nfolds, train=TRUE)@metrics$AUC)
cat(">> gbm_w_cartesian_bayesian_nfolds valid auc :", h2o.performance(gbm_w_cartesian_bayesian_nfolds, xval=TRUE)@metrics$AUC)
cat(">> gbm_w_cartesian_bayesian_nfolds test  auc :", h2o.performance(gbm_w_cartesian_bayesian_nfolds, newdata=test_hex)@metrics$AUC)



