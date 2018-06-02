# title : stopping_rules
# author : jacob
# desc : 


# stopping_rules
stopping_rules <- list(
  stopping_rounds = 3,
  stopping_metric = "logloss",
  stopping_tolerance = 0.01,
  score_each_iteration = TRUE,
  ntrees = 10000
)

cat(">> stopping_rules loaded! \n")