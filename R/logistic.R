# logistic.R
# Binary logistic regression with odds ratios, ROC curve, AUC and cross-validation
# (base R only). Requires helpers.R.
#
# Main function
#   logistic_regression(df, response, predictors, threshold = 0.5, folds = 5, out_dir = NULL)
#
# The response must have exactly two distinct values. The larger value (or the
# second one alphabetically) is treated as the "positive" class.

# ROC curve points and the area under the curve (trapezoid rule).
roc_curve <- function(prob, actual) {
  thresholds <- c(Inf, sort(unique(prob), decreasing = TRUE))
  tpr <- vapply(thresholds, function(t) mean(prob[actual == 1] >= t), numeric(1))
  fpr <- vapply(thresholds, function(t) mean(prob[actual == 0] >= t), numeric(1))
  auc <- sum(diff(fpr) * (head(tpr, -1) + tail(tpr, -1)) / 2)
  list(threshold = thresholds, tpr = tpr, fpr = fpr, auc = auc)
}

classification_metrics <- function(prob, actual, threshold) {
  predicted <- as.integer(prob >= threshold)
  tp <- sum(predicted == 1 & actual == 1)
  tn <- sum(predicted == 0 & actual == 0)
  fp <- sum(predicted == 1 & actual == 0)
  fn <- sum(predicted == 0 & actual == 1)
  precision <- if (tp + fp == 0) NA_real_ else tp / (tp + fp)
  recall <- tp / (tp + fn)
  list(
    confusion = matrix(c(tn, fn, fp, tp), 2,
                       dimnames = list(actual = c("0", "1"), predicted = c("0", "1"))),
    accuracy = (tp + tn) / length(actual),
    sensitivity = recall,
    specificity = tn / (tn + fp),
    precision = precision,
    f1 = if (is.na(precision) || precision + recall == 0) NA_real_ else 2 * precision * recall / (precision + recall)
  )
}

# Out-of-fold predicted probabilities from k-fold cross-validation.
cv_probabilities <- function(model_formula, data, folds, seed = 1) {
  fold_id <- make_folds(nrow(data), folds, seed)
  prob <- rep(NA_real_, nrow(data))
  for (fold in unique(fold_id)) {
    train <- data[fold_id != fold, , drop = FALSE]
    test <- data[fold_id == fold, , drop = FALSE]
    fit <- tryCatch(suppressWarnings(glm(model_formula, data = train, family = binomial)),
                    error = function(e) NULL)
    if (!is.null(fit)) {
      prob[fold_id == fold] <- suppressWarnings(predict(fit, test, type = "response"))
    }
  }
  prob
}

logistic_regression <- function(df, response, predictors, threshold = 0.5, folds = 5,
                                seed = 1, out_dir = NULL) {
  columns <- c(response, predictors)
  data <- df[complete.cases(df[columns]), columns, drop = FALSE]

  classes <- sort(unique(data[[response]]))
  if (length(classes) != 2) {
    stop(sprintf("The response must have exactly two distinct values (found %d).", length(classes)),
         call. = FALSE)
  }
  negative <- classes[1]
  positive <- classes[2]
  actual <- as.integer(data[[response]] == positive)
  data[[response]] <- actual

  n <- nrow(data)
  n_positive <- sum(actual)
  n_negative <- n - n_positive
  if (min(n_positive, n_negative) < 5) {
    stop("Each class needs at least 5 observations.", call. = FALSE)
  }

  model_formula <- build_formula(response, predictors)
  warnings_seen <- character(0)
  model <- withCallingHandlers(
    glm(model_formula, data = data, family = binomial),
    warning = function(w) {
      warnings_seen <<- c(warnings_seen, conditionMessage(w))
      invokeRestart("muffleWarning")
    }
  )
  model$call$formula <- model_formula
  model$call$data <- quote(data)

  section(sprintf("Logistic regression: %s ~ %s", response, paste(predictors, collapse = " + ")))
  cat(sprintf("Positive class (coded 1): %s  |  negative class (coded 0): %s\n", positive, negative))
  cat(sprintf("Observations: %d (%d positive, %d negative)\n", n, n_positive, n_negative))
  events_per_variable <- min(n_positive, n_negative) / length(coef(model)[-1])
  if (events_per_variable < 10) {
    cat(sprintf("Warning: only %.1f events per predictor (a common guideline is at least 10); estimates may be unstable.\n",
                events_per_variable))
  }
  if (length(warnings_seen) > 0) {
    cat("Warning from glm: ", paste(unique(warnings_seen), collapse = "; "), "\n", sep = "")
    if (any(grepl("0 or 1", warnings_seen))) {
      cat("Fitted probabilities of exactly 0 or 1 suggest (quasi-)complete separation; coefficients may be unreliable.\n")
    }
  }

  print(summary(model))

  coefs <- summary(model)$coefficients
  ci <- confint.default(model)[rownames(coefs), , drop = FALSE]
  odds <- data.frame(term = rownames(coefs), odds_ratio = exp(coefs[, 1]),
                     ci_low = exp(ci[, 1]), ci_high = exp(ci[, 2]),
                     p_value = coefs[, 4], row.names = NULL)
  cat("\nOdds ratios with 95% Wald confidence intervals:\n")
  shown <- odds
  shown$p_value <- format_p(shown$p_value)
  print(shown, digits = 4, row.names = FALSE)
  cat("An odds ratio above 1 raises the odds of the positive class; below 1 lowers them.\n")

  lr_stat <- model$null.deviance - model$deviance
  lr_df <- model$df.null - model$df.residual
  lr_p <- pchisq(lr_stat, lr_df, lower.tail = FALSE)
  mcfadden <- 1 - model$deviance / model$null.deviance
  cox_snell <- 1 - exp((model$deviance - model$null.deviance) / n)
  nagelkerke <- cox_snell / (1 - exp(-model$null.deviance / n))
  cat("\nModel fit:\n")
  cat(sprintf("  Likelihood-ratio test vs null model: chi-square = %.3f, df = %d, p = %s\n",
              lr_stat, lr_df, format_p(lr_p)))
  cat(sprintf("  McFadden R-squared = %.4f | Nagelkerke R-squared = %.4f | AIC = %.2f\n",
              mcfadden, nagelkerke, AIC(model)))

  prob <- fitted(model)
  roc <- roc_curve(prob, actual)
  rank_auc <- (sum(rank(prob)[actual == 1]) - n_positive * (n_positive + 1) / 2) /
    (n_positive * n_negative)
  youden <- roc$tpr - roc$fpr
  best <- which.max(youden)
  best_threshold <- roc$threshold[best]

  metrics <- classification_metrics(prob, actual, threshold)
  cat(sprintf("\nClassification at threshold %.2f (training data):\n", threshold))
  print(metrics$confusion)
  cat(sprintf("  Accuracy = %.4f | Sensitivity = %.4f | Specificity = %.4f | Precision = %s | F1 = %s\n",
              metrics$accuracy, metrics$sensitivity, metrics$specificity,
              if (is.na(metrics$precision)) "NA" else sprintf("%.4f", metrics$precision),
              if (is.na(metrics$f1)) "NA" else sprintf("%.4f", metrics$f1)))
  cat(sprintf("  Baseline accuracy (always predicting the majority class) = %.4f\n",
              max(n_positive, n_negative) / n))

  cat(sprintf("\nAUC (training data) = %.4f\n", rank_auc))
  cv_prob <- cv_probabilities(model_formula, data, folds, seed)
  cv_ok <- !is.na(cv_prob)
  cv_auc <- NA_real_
  if (sum(cv_ok) == n) {
    cv_auc <- roc_curve(cv_prob, actual)$auc
    cv_metrics <- classification_metrics(cv_prob, actual, threshold)
    cat(sprintf("%d-fold cross-validated AUC = %.4f, accuracy = %.4f  (a more honest estimate for new data)\n",
                max(make_folds(n, folds, seed)), cv_auc, cv_metrics$accuracy))
  } else {
    cat("Cross-validation could not be completed (a fold model failed to fit).\n")
  }
  cat(sprintf("Threshold that maximizes sensitivity + specificity (Youden): %.3f (sensitivity %.3f, specificity %.3f)\n",
              best_threshold, roc$tpr[best], 1 - roc$fpr[best]))

  draw <- function() {
    old <- par(mfrow = c(1, 2), mar = c(4.5, 4.5, 3, 1))
    on.exit(par(old))

    plot(roc$fpr, roc$tpr, type = "l", lwd = 3, col = "steelblue",
         xlab = "False positive rate (1 - specificity)", ylab = "True positive rate (sensitivity)",
         main = "ROC curve", xlim = c(0, 1), ylim = c(0, 1))
    abline(0, 1, lty = 2, col = "gray50")
    points(roc$fpr[best], roc$tpr[best], pch = 19, col = "red", cex = 1.6)
    legend("bottomright", bty = "n", cex = 0.9,
           legend = c(sprintf("AUC = %.3f", rank_auc),
                      sprintf("Best threshold = %.2f", best_threshold)),
           text.col = c("steelblue", "red"))
    grid()

    groups <- factor(ifelse(actual == 1, as.character(positive), as.character(negative)),
                     levels = c(as.character(negative), as.character(positive)))
    boxplot(prob ~ groups, col = c("#9ecae1", "#fcae91"), ylim = c(0, 1),
            xlab = "Actual class", ylab = "Predicted probability of the positive class",
            main = "Predicted probabilities")
    stripchart(prob ~ groups, vertical = TRUE, method = "jitter", pch = 19, cex = 0.6,
               col = adjustcolor("gray25", 0.5), add = TRUE)
    abline(h = threshold, lty = 2, col = "red")
  }
  render_plot(draw, out_file(out_dir, "logistic_regression.png"), width = 1400, height = 650)
  save_table(odds, out_dir, "logistic_odds_ratios.csv")

  invisible(list(model = model, odds_ratios = odds, auc = rank_auc, cv_auc = cv_auc,
                 metrics = metrics, roc = roc, best_threshold = best_threshold))
}
