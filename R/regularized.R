# regularized.R
# Ridge and lasso regression implemented from scratch (base R only).
# Requires helpers.R.
#
# Main function
#   regularized_regression(df, response, predictors, method = "lasso", folds = 10, out_dir = NULL)
#
# Objective (predictors standardized, y centered):
#   (1 / 2n) * sum of squared errors + lambda * penalty
#   lasso penalty = sum |beta|          ridge penalty = (1/2) * sum beta^2
# The penalty strength lambda is chosen by k-fold cross-validation.
#
# Verified against the glmnet package: lasso coefficients agree at the same lambda.
# For ridge, glmnet divides lambda by the standard deviation of y internally, so
# lambda values are not directly comparable between this file and glmnet.

standardize_matrix <- function(X) {
  center <- colMeans(X)
  scale <- sqrt(colMeans(sweep(X, 2, center)^2))
  scale[scale == 0] <- 1
  list(Z = sweep(sweep(X, 2, center), 2, scale, "/"), center = center, scale = scale)
}

soft_threshold <- function(z, gamma) {
  sign(z) * pmax(abs(z) - gamma, 0)
}

# Lasso by cyclic coordinate descent. Z must have columns with mean 0 and variance 1.
lasso_fit <- function(Z, y_centered, lambda, beta_start = NULL, tolerance = 1e-10,
                      max_iterations = 10000) {
  n <- nrow(Z)
  p <- ncol(Z)
  beta <- if (is.null(beta_start)) numeric(p) else beta_start
  residual <- as.vector(y_centered - Z %*% beta)

  for (iteration in seq_len(max_iterations)) {
    largest_change <- 0
    for (j in seq_len(p)) {
      z_j <- Z[, j]
      rho <- mean(z_j * residual) + beta[j]
      new_beta <- soft_threshold(rho, lambda)
      if (new_beta != beta[j]) {
        residual <- residual - z_j * (new_beta - beta[j])
        largest_change <- max(largest_change, abs(new_beta - beta[j]))
        beta[j] <- new_beta
      }
    }
    if (largest_change < tolerance) break
  }
  beta
}

# Ridge has a closed-form solution.
ridge_fit <- function(Z, y_centered, lambda) {
  n <- nrow(Z)
  p <- ncol(Z)
  as.vector(solve(crossprod(Z) / n + lambda * diag(p), crossprod(Z, y_centered) / n))
}

# Coefficients (standardized scale) for a decreasing sequence of lambdas: p x length(lambdas).
coefficient_path <- function(Z, y_centered, lambdas, method) {
  p <- ncol(Z)
  path <- matrix(0, p, length(lambdas))
  beta <- numeric(p)
  for (k in seq_along(lambdas)) {
    beta <- if (method == "lasso") {
      lasso_fit(Z, y_centered, lambdas[k], beta_start = beta)  # warm start
    } else {
      ridge_fit(Z, y_centered, lambdas[k])
    }
    path[, k] <- beta
  }
  path
}

# Cross-validated mean squared error for every lambda.
cv_regularized <- function(X, y, lambdas, method, fold_id) {
  k <- max(fold_id)
  fold_mse <- matrix(NA_real_, k, length(lambdas))
  for (fold in seq_len(k)) {
    train <- fold_id != fold
    std <- standardize_matrix(X[train, , drop = FALSE])
    y_mean <- mean(y[train])
    path <- coefficient_path(std$Z, y[train] - y_mean, lambdas, method)
    Z_test <- sweep(sweep(X[!train, , drop = FALSE], 2, std$center), 2, std$scale, "/")
    predictions <- y_mean + Z_test %*% path
    fold_mse[fold, ] <- colMeans((y[!train] - predictions)^2)
  }
  list(mean = colMeans(fold_mse), se = apply(fold_mse, 2, sd) / sqrt(k))
}

# Converts standardized coefficients back to the original units of the predictors.
to_original_scale <- function(beta, std, y_mean) {
  slopes <- beta / std$scale
  c(intercept = y_mean - sum(slopes * std$center), slopes)
}

regularized_regression <- function(df, response, predictors, method = c("lasso", "ridge"),
                                   folds = 10, seed = 1, out_dir = NULL) {
  method <- match.arg(method)
  not_numeric <- predictors[!vapply(df[predictors], is.numeric, logical(1))]
  if (length(not_numeric) > 0) {
    stop("Ridge and lasso support numeric predictors only: ",
         paste(not_numeric, collapse = ", "), call. = FALSE)
  }
  if (!is.numeric(df[[response]])) {
    stop("The response variable must be numeric.", call. = FALSE)
  }
  if (length(predictors) < 2) {
    stop("Choose at least 2 predictors.", call. = FALSE)
  }

  data <- df[complete.cases(df[c(response, predictors)]), c(response, predictors)]
  n <- nrow(data)
  if (n < 10) {
    stop("At least 10 complete rows are needed for cross-validation.", call. = FALSE)
  }
  X <- as.matrix(data[predictors])
  y <- data[[response]]
  p <- ncol(X)

  std <- standardize_matrix(X)
  y_mean <- mean(y)
  y_centered <- y - y_mean

  # Smallest lambda for which every lasso coefficient is zero (slightly increased
  # to avoid rounding noise).
  lambda_max <- max(abs(crossprod(std$Z, y_centered))) / n * (1 + 1e-9)
  lambdas <- if (method == "lasso") {
    lambda_max * 10^seq(0, -4, length.out = 60)
  } else {
    lambda_max * 10^seq(1, -4, length.out = 60)
  }

  fold_id <- make_folds(n, folds, seed)
  path <- coefficient_path(std$Z, y_centered, lambdas, method)
  cv <- cv_regularized(X, y, lambdas, method, fold_id)

  best_index <- which.min(cv$mean)
  limit <- cv$mean[best_index] + cv$se[best_index]
  one_se_index <- min(which(cv$mean <= limit))  # largest lambda within one standard error

  ols <- coef(lm(y ~ X))
  names(ols) <- c("intercept", predictors)
  at_one_se <- to_original_scale(path[, one_se_index], std, y_mean)
  at_best <- to_original_scale(path[, best_index], std, y_mean)

  section(sprintf("%s regression: %s ~ %s (n = %d)",
                  if (method == "lasso") "Lasso" else "Ridge", response,
                  paste(predictors, collapse = " + "), n))
  cat(sprintf("Lambda with the lowest CV error : %.5f (CV RMSE = %.4f)\n",
              lambdas[best_index], sqrt(cv$mean[best_index])))
  cat(sprintf("Largest lambda within 1 SE      : %.5f (CV RMSE = %.4f)  <- recommended\n",
              lambdas[one_se_index], sqrt(cv$mean[one_se_index])))
  cat("\nCoefficients in the original units of the predictors:\n")
  comparison <- data.frame(variable = names(ols), OLS = ols,
                           at_1se_lambda = at_one_se, at_min_cv_lambda = at_best,
                           row.names = NULL)
  print(comparison, digits = 4, row.names = FALSE)

  if (method == "lasso") {
    kept <- predictors[abs(at_one_se[-1]) > 1e-10]
    dropped <- setdiff(predictors, kept)
    cat(sprintf("\nLasso at the recommended lambda keeps %d of %d predictors: %s\n",
                length(kept), p, if (length(kept) == 0) "(none)" else paste(kept, collapse = ", ")))
    if (length(dropped) > 0) {
      cat(sprintf("Shrunk exactly to zero: %s\n", paste(dropped, collapse = ", ")))
    }
  } else {
    cat("\nRidge shrinks all coefficients toward zero but never sets them exactly to zero.\n")
    cat("It is most useful when predictors are strongly correlated.\n")
  }

  # R-squared of the recommended model on the training data (for reference only).
  fitted_values <- at_one_se[1] + X %*% at_one_se[-1]
  r2 <- 1 - sum((y - fitted_values)^2) / sum((y - y_mean)^2)
  cat(sprintf("Training R-squared at the recommended lambda: %.4f\n", r2))

  draw <- function() {
    old <- par(mfrow = c(1, 2), mar = c(4.5, 4.5, 3, 1))
    on.exit(par(old))
    log_lambda <- log10(lambdas)

    upper <- sqrt(cv$mean + cv$se)
    lower <- sqrt(pmax(cv$mean - cv$se, 0))
    plot(log_lambda, sqrt(cv$mean), type = "n", ylim = range(lower, upper),
         xlab = "log10(lambda)", ylab = "Cross-validated RMSE", main = "Choosing lambda")
    segments(log_lambda, lower, log_lambda, upper, col = "gray70")
    points(log_lambda, sqrt(cv$mean), pch = 19, col = "steelblue", cex = 0.8)
    abline(v = log_lambda[best_index], lty = 2, col = "darkgreen")
    abline(v = log_lambda[one_se_index], lty = 2, col = "red")
    legend("topleft", legend = c("Lowest CV error", "Within 1 SE (recommended)"),
           col = c("darkgreen", "red"), lty = 2, bg = "white", cex = 0.8)
    grid()

    colors <- rainbow(p, s = 0.8, v = 0.75)
    matplot(log_lambda, t(path), type = "l", lty = 1, lwd = 2, col = colors,
            xlab = "log10(lambda)", ylab = "Standardized coefficient",
            main = "Coefficient paths")
    abline(v = log_lambda[one_se_index], lty = 2, col = "red")
    abline(h = 0, col = "gray50")
    legend("topright", legend = predictors, col = colors, lty = 1, lwd = 2, bg = "white",
           cex = 0.7, ncol = if (p > 8) 2 else 1)
  }
  render_plot(draw, out_file(out_dir, paste0(method, "_regression.png")), width = 1400, height = 650)
  save_table(comparison, out_dir, paste0(method, "_coefficients.csv"))

  invisible(list(method = method, lambdas = lambdas, path = path, cv = cv,
                 lambda_min = lambdas[best_index], lambda_1se = lambdas[one_se_index],
                 coefficients_1se = at_one_se, coefficients_min = at_best, ols = ols))
}
