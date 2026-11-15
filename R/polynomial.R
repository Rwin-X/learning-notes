# polynomial.R
# Polynomial regression with automatic degree selection (base R only).
# Requires helpers.R.
#
# Main function
#   polynomial_regression(df, x_name, y_name, max_degree = 5, folds = 5, out_dir = NULL)
#
# Degrees 1..max_degree are fitted and compared with R-squared, adjusted R-squared,
# AIC, BIC and k-fold cross-validated RMSE (the most reliable guard against overfitting).
# The selected degree is the simplest one whose cross-validated error is within one
# standard error of the lowest (the "one standard error rule").

polynomial_regression <- function(df, x_name, y_name, max_degree = 5, folds = 5,
                                  seed = 1, out_dir = NULL) {
  data <- df[complete.cases(df[c(x_name, y_name)]), c(x_name, y_name)]
  if (!is.numeric(data[[x_name]]) || !is.numeric(data[[y_name]])) {
    stop("Both x and y must be numeric.", call. = FALSE)
  }

  x <- data[[x_name]]
  y <- data[[y_name]]
  n <- length(x)
  max_degree <- min(max_degree, length(unique(x)) - 1, n - 3)
  if (max_degree < 1) {
    stop("Not enough distinct x values or rows for a polynomial fit.", call. = FALSE)
  }

  # x is centered to keep the polynomial terms numerically stable.
  center <- mean(x)
  dat <- data.frame(y = y, xc = x - center)
  fold_id <- make_folds(n, folds, seed)

  fit_degree <- function(d, d_data) {
    lm(as.formula(sprintf("y ~ poly(xc, %d, raw = TRUE)", d)), data = d_data)
  }

  results <- data.frame(degree = seq_len(max_degree), r_squared = NA_real_,
                        adj_r_squared = NA_real_, aic = NA_real_, bic = NA_real_,
                        cv_rmse = NA_real_)
  models <- vector("list", max_degree)
  fold_mse <- matrix(NA_real_, nrow = max_degree, ncol = max(fold_id))

  for (d in seq_len(max_degree)) {
    model <- fit_degree(d, dat)
    models[[d]] <- model
    s <- summary(model)

    squared_errors <- rep(NA_real_, n)
    for (fold in unique(fold_id)) {
      train <- dat[fold_id != fold, , drop = FALSE]
      test <- dat[fold_id == fold, , drop = FALSE]
      if (nrow(train) <= d + 1) next
      fold_model <- fit_degree(d, train)
      squared_errors[fold_id == fold] <- (test$y - suppressWarnings(predict(fold_model, test)))^2
      fold_mse[d, fold] <- mean(squared_errors[fold_id == fold])
    }

    results[d, -1] <- c(s$r.squared, s$adj.r.squared, AIC(model), BIC(model),
                        if (anyNA(squared_errors)) NA_real_ else sqrt(mean(squared_errors)))
  }

  # One standard error rule on the fold-level mean squared errors.
  mean_mse <- rowMeans(fold_mse)
  se_mse <- apply(fold_mse, 1, sd) / sqrt(ncol(fold_mse))
  best_min <- if (all(is.na(mean_mse))) NA else which.min(mean_mse)
  if (is.na(best_min)) {
    best_cv <- NA
  } else {
    limit <- mean_mse[best_min] + se_mse[best_min]
    if (is.na(limit)) limit <- mean_mse[best_min]
    best_cv <- min(which(mean_mse <= limit))
  }
  best_bic <- results$degree[which.min(results$bic)]
  best_adj <- results$degree[which.max(results$adj_r_squared)]
  best <- if (is.na(best_cv)) best_bic else best_cv
  best_model <- models[[best]]

  section(sprintf("Polynomial regression: %s ~ polynomial in %s (n = %d)", y_name, x_name, n))
  shown <- results
  shown$best_by <- vapply(shown$degree, function(d) {
    tags <- c(if (!is.na(best_min) && d == best_min) "CVmin",
              if (!is.na(best_cv) && d == best_cv) "CV1se",
              if (d == best_bic) "BIC", if (d == best_adj) "adjR2")
    paste(tags, collapse = ",")
  }, character(1))
  print(shown, digits = 4, row.names = FALSE)

  if (is.na(best_cv)) {
    cat(sprintf("\nSelected degree: %d (chosen by BIC; cross-validation was not possible)\n", best))
  } else {
    cat(sprintf("\nSelected degree: %d (simplest model within one standard error of the best cross-validated error)\n", best))
    cat(sprintf("Lowest cross-validated error: degree %d | BIC prefers degree %d | adjusted R-squared prefers degree %d\n",
                best_min, best_bic, best_adj))
  }
  if (best == max_degree) {
    cat("The best degree is the highest one tested; try a larger maximum degree.\n")
  }

  cf <- coef(best_model)
  terms <- vapply(seq_along(cf)[-1], function(i) {
    sprintf(" %s %.4g*(%s - %.4g)^%d", if (cf[i] < 0) "-" else "+", abs(cf[i]),
            x_name, center, i - 1)
  }, character(1))
  cat(sprintf("\nFitted equation: %s = %.4g%s\n", y_name, cf[1], paste(terms, collapse = "")))
  cat(sprintf("Residual standard error: %.4f, R-squared: %.4f\n",
              summary(best_model)$sigma, summary(best_model)$r.squared))
  cat("\nCoefficients of the selected model (x centered at its mean):\n")
  print(round(summary(best_model)$coefficients, 5))

  draw <- function() {
    old <- par(mfrow = c(1, 2), mar = c(4.5, 4.5, 3, 1))
    on.exit(par(old))

    grid_x <- seq(min(x), max(x), length.out = 300)
    grid_data <- data.frame(xc = grid_x - center)
    plot(x, y, pch = 19, col = adjustcolor("steelblue", 0.8), xlab = x_name, ylab = y_name,
         main = "Polynomial fits")
    palette <- colorRampPalette(c("gray80", "gray45"))(max_degree)
    for (d in setdiff(seq_len(max_degree), best)) {
      lines(grid_x, predict(models[[d]], grid_data), col = palette[d], lwd = 1)
    }
    lines(grid_x, predict(best_model, grid_data), col = "red", lwd = 3)
    legend("topleft", legend = c(sprintf("Selected: degree %d", best), "Other degrees"),
           col = c("red", "gray60"), lwd = c(3, 1), bg = "white", cex = 0.85)

    plot(results$degree, results$cv_rmse, type = "b", pch = 19, col = "steelblue",
         xlab = "Polynomial degree", ylab = "Cross-validated RMSE",
         main = "Choosing the degree", xaxt = "n")
    axis(1, at = results$degree)
    points(best, results$cv_rmse[best], pch = 19, col = "red", cex = 1.8)
    grid()
  }
  render_plot(draw, out_file(out_dir, "polynomial_regression.png"), width = 1400, height = 650)
  save_table(results, out_dir, "polynomial_comparison.csv")

  invisible(list(table = results, best_degree = best, model = best_model, models = models,
                 center = center))
}
