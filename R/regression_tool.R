#!/usr/bin/env Rscript
# =============================================================================
# regression_tool.R
# A self-contained regression toolkit written in base R (no extra packages).
#
# Features
#   1. Manual OLS via matrix algebra (to see exactly what lm() computes)
#   2. Linear regression (lm) and GLM (logistic / Poisson) with one interface
#   3. Diagnostics: VIF, Durbin-Watson, Breusch-Pagan, Shapiro-Wilk, Cook's D
#   4. Diagnostic plots saved to PNG
#   5. Prediction on new data with intervals
#   6. Command line usage
#
# Command line usage
#   Rscript regression_tool.R <data.csv> "<formula>" [family] [output_dir]
#
#   family: gaussian (default) | binomial | poisson
#
# Examples
#   Rscript regression_tool.R cars.csv "mpg ~ wt + hp"
#   Rscript regression_tool.R cars.csv "am ~ wt + hp" binomial results
#
# Run without arguments to execute a demo on the built-in mtcars dataset.
#
# Interactive usage
#   source("regression_tool.R")
#   res <- run_regression(mtcars, mpg ~ wt + hp)
# =============================================================================


# -----------------------------------------------------------------------------
# 1. Manual OLS using the normal equations: beta = (X'X)^-1 X'y
# -----------------------------------------------------------------------------
ols_manual <- function(formula, data) {
  mf <- model.frame(formula, data)          # drops rows with missing values
  y  <- model.response(mf)
  X  <- model.matrix(formula, mf)

  n <- nrow(X)
  p <- ncol(X)
  has_intercept <- "(Intercept)" %in% colnames(X)

  XtX_inv <- solve(crossprod(X))
  beta    <- as.vector(XtX_inv %*% crossprod(X, y))
  names(beta) <- colnames(X)

  fitted_values <- as.vector(X %*% beta)
  residuals_    <- as.vector(y) - fitted_values

  rss    <- sum(residuals_^2)
  tss    <- if (has_intercept) sum((y - mean(y))^2) else sum(y^2)
  df_res <- n - p
  df_mod <- p - as.integer(has_intercept)
  sigma2 <- rss / df_res

  se   <- sqrt(diag(XtX_inv) * sigma2)
  tval <- beta / se
  pval <- 2 * pt(abs(tval), df = df_res, lower.tail = FALSE)

  r2     <- 1 - rss / tss
  adj_r2 <- 1 - (1 - r2) * (n - as.integer(has_intercept)) / df_res
  fstat  <- ((tss - rss) / df_mod) / sigma2
  f_p    <- pf(fstat, df_mod, df_res, lower.tail = FALSE)

  list(
    coefficients = data.frame(
      estimate  = beta,
      std_error = se,
      t_value   = tval,
      p_value   = pval
    ),
    r_squared     = r2,
    adj_r_squared = adj_r2,
    sigma         = sqrt(sigma2),
    f_statistic   = fstat,
    f_p_value     = f_p,
    df            = c(model = df_mod, residual = df_res)
  )
}


# -----------------------------------------------------------------------------
# 2. Diagnostic helpers (for linear models)
# -----------------------------------------------------------------------------

# Variance inflation factor: VIF_j = 1 / (1 - R2_j), where R2_j comes from
# regressing predictor j on all the other predictors.
vif_table <- function(model) {
  X <- model.matrix(model)
  X <- X[, colnames(X) != "(Intercept)", drop = FALSE]
  if (ncol(X) < 2) {
    return(NULL)
  }
  vifs <- sapply(seq_len(ncol(X)), function(j) {
    r2 <- summary(lm(X[, j] ~ X[, -j, drop = FALSE]))$r.squared
    1 / (1 - r2)
  })
  data.frame(variable = colnames(X), VIF = vifs, row.names = NULL)
}

# Durbin-Watson statistic. Values near 2 suggest no first-order autocorrelation.
durbin_watson <- function(model) {
  e <- residuals(model)
  sum(diff(e)^2) / sum(e^2)
}

# Breusch-Pagan test (studentized / Koenker version).
# H0: constant error variance (homoscedasticity).
breusch_pagan <- function(model) {
  X <- model.matrix(model)
  X <- X[, colnames(X) != "(Intercept)", drop = FALSE]
  if (ncol(X) < 1) {
    return(NULL)
  }
  e2  <- residuals(model)^2
  aux <- summary(lm(e2 ~ X))
  lm_stat <- length(e2) * aux$r.squared
  df <- ncol(X)
  c(statistic = lm_stat, df = df,
    p_value = pchisq(lm_stat, df, lower.tail = FALSE))
}

run_diagnostics <- function(model) {
  n <- length(residuals(model))
  p <- length(coef(model))

  cat("\n--- Diagnostics ---\n")

  if (n >= 3 && n <= 5000) {
    sw <- shapiro.test(residuals(model))
    cat(sprintf("Shapiro-Wilk (residual normality): W = %.4f, p = %.4f\n",
                sw$statistic, sw$p.value))
  }

  bp <- breusch_pagan(model)
  if (!is.null(bp)) {
    cat(sprintf("Breusch-Pagan (heteroscedasticity): LM = %.4f, df = %d, p = %.4f\n",
                bp["statistic"], as.integer(bp["df"]), bp["p_value"]))
  }

  cat(sprintf("Durbin-Watson (autocorrelation): DW = %.4f\n",
              durbin_watson(model)))

  v <- vif_table(model)
  if (!is.null(v)) {
    cat("\nVariance inflation factors (values above 5-10 indicate collinearity):\n")
    print(v, row.names = FALSE, digits = 4)
  }

  cd <- cooks.distance(model)
  threshold <- 4 / n
  flagged <- which(cd > threshold)
  cat(sprintf("\nCook's distance: %d observation(s) above 4/n = %.4f\n",
              length(flagged), threshold))
  if (length(flagged) > 0) {
    top <- head(sort(cd[flagged], decreasing = TRUE), 5)
    print(round(top, 4))
  }

  hat_threshold <- 2 * p / n
  high_lev <- which(hatvalues(model) > hat_threshold)
  cat(sprintf("High leverage points (hat > 2p/n = %.4f): %d\n",
              hat_threshold, length(high_lev)))

  invisible(NULL)
}


# -----------------------------------------------------------------------------
# 3. Main entry point
# -----------------------------------------------------------------------------
run_regression <- function(data, formula,
                           family = c("gaussian", "binomial", "poisson"),
                           output_dir = NULL,
                           diagnostics = TRUE) {
  family <- match.arg(family)
  formula <- as.formula(formula)

  cat("=============================================================\n")
  cat("Formula :", deparse(formula), "\n")
  cat("Family  :", family, "\n")
  cat("Rows    :", nrow(data), "\n")
  cat("=============================================================\n")

  if (family == "gaussian") {
    model <- lm(formula, data = data)
    print(summary(model))

    cat("\n95% confidence intervals:\n")
    print(round(confint(model), 4))

    cat("\nCross-check with manual OLS (matrix algebra):\n")
    manual <- ols_manual(formula, data)
    print(round(manual$coefficients, 5))
    cat(sprintf("R-squared = %.5f | Adj. R-squared = %.5f | F = %.4f (p = %.4g)\n",
                manual$r_squared, manual$adj_r_squared,
                manual$f_statistic, manual$f_p_value))

    if (diagnostics) {
      run_diagnostics(model)
    }
  } else {
    model <- glm(formula, data = data, family = family)
    print(summary(model))

    # Wald confidence intervals and exponentiated coefficients
    est <- coef(model)
    ci  <- confint.default(model)
    label <- if (family == "binomial") "Odds ratios" else "Rate ratios"
    cat(sprintf("\n%s (exp(coef)) with 95%% Wald CI:\n", label))
    print(round(cbind(ratio = exp(est), exp(ci)), 4))

    # McFadden pseudo R-squared
    pseudo_r2 <- 1 - model$deviance / model$null.deviance
    cat(sprintf("\nMcFadden pseudo R-squared: %.4f\n", pseudo_r2))
    cat(sprintf("AIC: %.3f\n", AIC(model)))

    if (family == "binomial") {
      pred <- as.integer(fitted(model) >= 0.5)
      actual <- model$y
      acc <- mean(pred == actual)
      cat(sprintf("Classification accuracy (cutoff 0.5): %.4f\n", acc))
      cat("Confusion matrix (rows = actual, columns = predicted):\n")
      print(table(actual = actual, predicted = pred))
    }
  }

  if (!is.null(output_dir)) {
    save_outputs(model, output_dir, family)
  }

  invisible(model)
}


# -----------------------------------------------------------------------------
# 4. Saving results and plots
# -----------------------------------------------------------------------------
save_outputs <- function(model, output_dir, family) {
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  # Coefficient table as CSV
  coef_table <- as.data.frame(summary(model)$coefficients)
  coef_table <- cbind(term = rownames(coef_table), coef_table)
  write.csv(coef_table, file.path(output_dir, "coefficients.csv"),
            row.names = FALSE)

  # Diagnostic plots (the standard 2x2 panel)
  png(file.path(output_dir, "diagnostic_plots.png"),
      width = 1200, height = 1000, res = 130)
  op <- par(mfrow = c(2, 2))
  plot(model)
  par(op)
  dev.off()

  cat(sprintf("\nSaved: %s and %s\n",
              file.path(output_dir, "coefficients.csv"),
              file.path(output_dir, "diagnostic_plots.png")))
}


# -----------------------------------------------------------------------------
# 5. Prediction helper
# -----------------------------------------------------------------------------
predict_new <- function(model, newdata, level = 0.95) {
  if (inherits(model, "glm")) {
    out <- data.frame(newdata,
                      prediction = predict(model, newdata, type = "response"))
  } else {
    pi <- predict(model, newdata, interval = "prediction", level = level)
    out <- data.frame(newdata, pi)
  }
  out
}


# -----------------------------------------------------------------------------
# 6. Command line interface
# -----------------------------------------------------------------------------
main <- function() {
  args <- commandArgs(trailingOnly = TRUE)

  if (length(args) == 0) {
    cat("No arguments supplied: running demo on mtcars.\n\n")
    model <- run_regression(mtcars, mpg ~ wt + hp + qsec,
                            output_dir = "regression_output")

    cat("\n--- Prediction example ---\n")
    new_cars <- data.frame(wt = c(2.5, 3.5), hp = c(100, 180), qsec = c(18, 17))
    print(round(predict_new(model, new_cars), 3))
    return(invisible(NULL))
  }

  if (length(args) < 2) {
    stop("Usage: Rscript regression_tool.R <data.csv> \"<formula>\" [family] [output_dir]")
  }

  data_path  <- args[1]
  formula    <- args[2]
  family     <- if (length(args) >= 3) args[3] else "gaussian"
  output_dir <- if (length(args) >= 4) args[4] else NULL

  if (!file.exists(data_path)) {
    stop(sprintf("Data file not found: %s", data_path))
  }

  data <- read.csv(data_path, stringsAsFactors = TRUE)
  run_regression(data, formula, family = family, output_dir = output_dir)
}

# Run main() only when executed via Rscript, not when sourced.
if (sys.nframe() == 0) {
  main()
}
