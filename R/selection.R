# selection.R
# Variable selection for linear regression (base R only). Requires helpers.R.
#
# Main function
#   best_subsets(df, response, predictors, folds = 5, out_dir = NULL)
#
# Every combination of the predictors is fitted and ranked by cross-validated RMSE,
# BIC and adjusted R-squared. Stepwise selection by AIC is shown for comparison.

best_subsets <- function(df, response, predictors, folds = 5, seed = 1,
                         max_predictors = 10, out_dir = NULL) {
  not_numeric <- predictors[!vapply(df[predictors], is.numeric, logical(1))]
  if (length(not_numeric) > 0) {
    stop("Variable selection supports numeric predictors only: ",
         paste(not_numeric, collapse = ", "), call. = FALSE)
  }
  if (!is.numeric(df[[response]])) {
    stop("The response variable must be numeric.", call. = FALSE)
  }
  p <- length(predictors)
  if (p < 2) {
    stop("Choose at least 2 predictors.", call. = FALSE)
  }
  if (p > max_predictors) {
    stop(sprintf("Too many predictors (%d). The limit is %d because all combinations are tested.",
                 p, max_predictors), call. = FALSE)
  }

  data <- df[complete.cases(df[c(response, predictors)]), c(response, predictors)]
  n <- nrow(data)
  if (n < p + 3) {
    stop("Too few complete rows for this many predictors.", call. = FALSE)
  }
  y <- data[[response]]
  X <- as.matrix(data[predictors])
  fold_id <- make_folds(n, folds, seed)
  total_ss <- sum((y - mean(y))^2)

  subsets <- unlist(lapply(seq_len(p), function(k) combn(p, k, simplify = FALSE)),
                    recursive = FALSE)

  results <- do.call(rbind, lapply(subsets, function(idx) {
    design <- cbind(1, X[, idx, drop = FALSE])
    k <- length(idx)

    fit <- lm.fit(design, y)
    rss <- sum(fit$residuals^2)
    log_lik_term <- n * (log(2 * pi) + 1 + log(rss / n))

    squared_errors <- numeric(n)
    for (fold in unique(fold_id)) {
      train <- fold_id != fold
      beta <- lm.fit(design[train, , drop = FALSE], y[train])$coefficients
      beta[is.na(beta)] <- 0
      squared_errors[!train] <- (y[!train] - design[!train, , drop = FALSE] %*% beta)^2
    }

    data.frame(predictors = paste(predictors[idx], collapse = " + "), n_predictors = k,
               r_squared = 1 - rss / total_ss,
               adj_r_squared = 1 - (rss / (n - k - 1)) / (total_ss / (n - 1)),
               aic = log_lik_term + 2 * (k + 2), bic = log_lik_term + log(n) * (k + 2),
               cv_rmse = sqrt(mean(squared_errors)))
  }))
  results <- results[order(results$cv_rmse), ]
  rownames(results) <- NULL

  section(sprintf("Variable selection for %s (%d predictors, %d models tested)",
                  response, p, nrow(results)))
  cat("Top 10 models by cross-validated RMSE:\n")
  print(head(results, 10), digits = 4, row.names = FALSE)

  best_cv <- results[1, ]
  best_bic <- results[which.min(results$bic), ]
  best_adj <- results[which.max(results$adj_r_squared), ]
  cat("\nBest model by each criterion:\n")
  cat(sprintf("  Cross-validated RMSE : %s  (RMSE = %.4f)\n", best_cv$predictors, best_cv$cv_rmse))
  cat(sprintf("  BIC                  : %s  (BIC = %.2f)\n", best_bic$predictors, best_bic$bic))
  cat(sprintf("  Adjusted R-squared   : %s  (%.4f)\n", best_adj$predictors, best_adj$adj_r_squared))

  # Stepwise selection by AIC, for comparison.
  full_formula <- build_formula(response, predictors)
  full_model <- lm(full_formula, data = data)
  null_model <- lm(as.formula(sprintf("`%s` ~ 1", response)), data = data)
  stepwise <- suppressWarnings(step(null_model, direction = "both", trace = 0,
                                    scope = list(lower = ~1, upper = formula(full_model))))
  chosen <- setdiff(attr(terms(stepwise), "term.labels"), character(0))
  chosen <- gsub("`", "", chosen)
  cat(sprintf("\nStepwise selection (AIC, both directions): %s\n",
              if (length(chosen) == 0) "(no predictors)" else paste(chosen, collapse = " + ")))
  cat("Note: agreement between criteria gives more confidence; if they disagree,\n")
  cat("prefer the simpler model unless the extra variables are scientifically important.\n")

  best_formula <- build_formula(response, strsplit(best_cv$predictors, " \\+ ")[[1]])
  best_model <- lm(best_formula, data = data)
  best_model$call$formula <- best_formula
  best_model$call$data <- quote(data)
  cat("\nSelected model (lowest cross-validated RMSE):\n")
  print(summary(best_model)$coefficients, digits = 4)

  draw <- function() {
    old <- par(mfrow = c(1, 2), mar = c(4.5, 4.5, 3, 1))
    on.exit(par(old))
    for (criterion in c("cv_rmse", "bic")) {
      values <- results[[criterion]]
      plot(results$n_predictors, values, pch = 19, col = adjustcolor("gray50", 0.5),
           xlab = "Number of predictors", ylab = if (criterion == "cv_rmse") "Cross-validated RMSE" else "BIC",
           main = if (criterion == "cv_rmse") "All models: CV RMSE" else "All models: BIC", xaxt = "n")
      axis(1, at = seq_len(p))
      per_size <- tapply(values, results$n_predictors, min)
      lines(as.integer(names(per_size)), per_size, type = "b", pch = 19, col = "steelblue", lwd = 2)
      best_value <- min(values)
      points(results$n_predictors[which.min(values)], best_value, pch = 19, col = "red", cex = 1.8)
      grid()
    }
  }
  render_plot(draw, out_file(out_dir, "variable_selection.png"), width = 1400, height = 650)
  save_table(results, out_dir, "variable_selection_models.csv")

  invisible(list(table = results, best_cv = best_cv, best_bic = best_bic,
                 best_adj = best_adj, stepwise = chosen, model = best_model))
}
