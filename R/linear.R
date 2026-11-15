# linear.R
# Multiple linear regression with a full set of diagnostics (base R only).
# Requires helpers.R.
#
# Main function
#   linear_regression(df, response, predictors, out_dir = NULL)
#
# Also usable on any lm model:
#   vif_table(model), durbin_watson(model), breusch_pagan(model), influence_table(model)

# Variance inflation factors: VIF_j = 1 / (1 - R2_j), where R2_j comes from
# regressing predictor j on all the other predictors.
vif_table <- function(model) {
  X <- model.matrix(model)
  X <- X[, colnames(X) != "(Intercept)", drop = FALSE]
  if (ncol(X) < 2) {
    return(NULL)
  }
  vifs <- vapply(seq_len(ncol(X)), function(j) {
    r2 <- summary(lm(X[, j] ~ X[, -j, drop = FALSE]))$r.squared
    1 / (1 - r2)
  }, numeric(1))
  data.frame(variable = colnames(X), VIF = vifs, row.names = NULL)
}

# Durbin-Watson statistic: about 2 means no first-order autocorrelation.
# It is meaningful only when the rows are in a natural order (for example time).
durbin_watson <- function(model) {
  e <- residuals(model)
  sum(diff(e)^2) / sum(e^2)
}

# Breusch-Pagan test (studentized): H0 = constant error variance.
breusch_pagan <- function(model) {
  X <- model.matrix(model)
  X <- X[, colnames(X) != "(Intercept)", drop = FALSE]
  e2 <- residuals(model)^2
  lm_stat <- length(e2) * summary(lm(e2 ~ X))$r.squared
  c(statistic = lm_stat, df = ncol(X), p_value = pchisq(lm_stat, ncol(X), lower.tail = FALSE))
}

# Observations with high Cook's distance, leverage or standardized residual.
influence_table <- function(model) {
  n <- nobs(model)
  p <- sum(!is.na(coef(model)))
  cooks <- cooks.distance(model)
  leverage <- hatvalues(model)
  std_resid <- rstandard(model)

  flag <- cooks > 4 / n | leverage > 2 * p / n | abs(std_resid) > 3
  flag[is.na(flag)] <- FALSE
  if (!any(flag)) {
    return(NULL)
  }
  data.frame(observation = names(cooks)[flag], cooks_distance = cooks[flag],
             leverage = leverage[flag], std_residual = std_resid[flag], row.names = NULL)
}

draw_fit_plot <- function(model) {
  observed <- model.response(model.frame(model))
  fitted_values <- fitted(model)
  r2 <- summary(model)$r.squared
  plot(fitted_values, observed, pch = 19, col = adjustcolor("steelblue", 0.8),
       xlab = "Fitted values", ylab = "Observed values",
       main = sprintf("Observed vs fitted (R-squared = %.3f)", r2))
  abline(0, 1, col = "red", lwd = 2)
  grid()
}

draw_diagnostic_plots <- function(model) {
  old <- par(mfrow = c(2, 2))
  on.exit(par(old))
  plot(model, which = c(1, 2, 3, 5))
}

linear_regression <- function(df, response, predictors, out_dir = NULL) {
  columns <- c(response, predictors)
  data <- df[complete.cases(df[columns]), columns, drop = FALSE]

  if (!is.numeric(data[[response]])) {
    stop("The response variable must be numeric.", call. = FALSE)
  }
  if (nrow(data) < length(predictors) + 3) {
    stop(sprintf("Too few complete rows (%d) for %d predictors.", nrow(data), length(predictors)),
         call. = FALSE)
  }

  model_formula <- build_formula(response, predictors)
  model <- lm(model_formula, data = data)
  model$call$formula <- model_formula  # a readable Call line in summary()
  model$call$data <- quote(data)

  section(sprintf("Linear regression: %s ~ %s", response, paste(predictors, collapse = " + ")))
  if (nrow(data) < nrow(df)) {
    cat(sprintf("Rows used: %d of %d (rows with missing values were dropped)\n",
                nrow(data), nrow(df)))
  }
  print(summary(model))

  cat("\n95% confidence intervals:\n")
  print(round(confint(model), 4))

  # Standardized coefficients: effect in standard deviations of y per standard
  # deviation of each predictor (makes predictors with different units comparable).
  X <- model.matrix(model)[, -1, drop = FALSE]
  y_sd <- sd(model.response(model.frame(model)))
  std_beta <- coef(model)[colnames(X)] * apply(X, 2, sd) / y_sd
  cat("\nStandardized coefficients (beta weights):\n")
  print(round(std_beta, 4))

  vif <- vif_table(model)
  if (!is.null(vif)) {
    cat("\nVariance inflation factors (above 5-10 suggests multicollinearity):\n")
    print(vif, digits = 4, row.names = FALSE)
  }

  cat("\n--- Residual diagnostics ---\n")
  n <- nobs(model)
  tests <- list()
  if (n >= 3 && n <= 5000) {
    sw <- shapiro.test(residuals(model))
    tests$shapiro <- c(W = unname(sw$statistic), p_value = sw$p.value)
    cat(sprintf("Shapiro-Wilk (normal residuals):   W = %.4f, p = %s\n",
                sw$statistic, format_p(sw$p.value)))
  }
  bp <- breusch_pagan(model)
  tests$breusch_pagan <- bp
  cat(sprintf("Breusch-Pagan (equal variance):    LM = %.4f, df = %d, p = %s\n",
              bp["statistic"], as.integer(bp["df"]), format_p(bp["p_value"])))
  dw <- durbin_watson(model)
  tests$durbin_watson <- dw
  cat(sprintf("Durbin-Watson (autocorrelation):   DW = %.4f\n", dw))
  cat("A p-value below 0.05 in the first two tests suggests the assumption is violated.\n")

  influence <- influence_table(model)
  if (is.null(influence)) {
    cat("\nNo influential observations flagged.\n")
  } else {
    cat("\nPossibly influential observations (Cook's D > 4/n, leverage > 2p/n or |std. residual| > 3):\n")
    print(influence, digits = 3, row.names = FALSE)
  }

  render_plot(function() draw_fit_plot(model), out_file(out_dir, "linear_fit.png"))
  render_plot(function() draw_diagnostic_plots(model), out_file(out_dir, "linear_diagnostics.png"))

  if (!is.null(out_dir)) {
    coefficients <- cbind(term = rownames(summary(model)$coefficients),
                          as.data.frame(summary(model)$coefficients), confint(model)[
                            rownames(summary(model)$coefficients), , drop = FALSE])
    save_table(coefficients, out_dir, "linear_coefficients.csv")
  }

  invisible(list(model = model, vif = vif, tests = tests, influence = influence))
}
