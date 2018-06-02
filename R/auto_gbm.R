#' @title autoGBM
#' @description auto train GBM using pre-defined strategies
#' @param data_hex H2ODataFrame
#' @param x independent variables
#' @param y dependent variable
#' @examples
#' library(rBayesianOptimization)
#' library(h2o)
#' h2o.init()
#' data(churn, package = "rAutoML")
#' data_hex <- as.h2o(churn)
#' split_hex <- h2o.splitFrame(data = data_hex, ratios = c(0.5,0.3), seed = 1234)
#' train_hex <- split_hex[[1]]
#' valid_hex <- split_hex[[2]]
#' test_hex <- split_hex[[3]]
#' y = "Churn."
#' x = colnames(data_hex)[colnames(data_hex)!=y]
#' output <- autoGBM(training_frame=train_hex, validation_frame_valid_hex, x=x, y=y)
#' @export
autoGBM <- function(training_frame, validation_frame, x, y){

  # run expriment
  path = 'R/gbm'
  source(file.path(path, 'gbm_w_default.R'))
  source(file.path(path, 'gbm_w_stoppingRules.R'))
  source(file.path(path, 'gbm_w_cartesian.R'))
  source(file.path(path, 'gbm_w_random.R'))
  source(file.path(path, 'gbm_w_cartesianRandom.R'))
  source(file.path(path, 'gbm_w_cartesianRandom_nfolds.R'))
  source(file.path(path, 'gbm_w_bayesian.R'))
  source(file.path(path, 'gbm_w_bayesian_nfolds.R'))
  source(file.path(path, 'gbm_w_cartesian_bayesian_nfolds.R'))

  # collect model
  gbm_list <- list(
    gbm_w_default,
    gbm_w_stoppingRules,
    gbm_w_cartesian,
    gbm_w_random,
    gbm_w_cartesianRandom,
    gbm_w_cartesianRandom_nfolds,
    gbm_w_bayesian,
    gbm_w_bayesian_nfolds,
    gbm_w_cartesian_bayesian_nfolds
  )

  # make report
  gbm_report <- data.frame(
    "model" = c("default","stop","cartes","random","cartRan","cartRanCV","bayes","bayesCV","carBayCV"),
    "train" = sapply(gbm_list, function(x) h2o.performance(x, train=TRUE)@metrics$AUC),
    "test" = sapply(gbm_list, function(x) h2o.performance(x, newdata=test_hex)@metrics$AUC)
  )

  return(gbm_summary)
}




















