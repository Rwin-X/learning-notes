# timeseries.R
# Time series forecasting with automatic method comparison (base R only).
# Requires helpers.R.
#
# Main function
#   time_series_analysis(df, value, time = NULL, horizon = 6, holdout = NULL,
#                        season_length = NULL, ma_window = 3, out_dir = NULL)
#
# Methods compared on a holdout period (the last observations):
#   naive, linear trend, moving average, simple exponential smoothing, Holt's linear
#   trend and, when `season_length` is given, seasonal naive and additive Holt-Winters.
# The method with the lowest holdout RMSE is refitted on all the data and used for
# the forecast. The rows of the data must be in chronological order.
#
# Verified against stats::HoltWinters (same smoothing parameters and errors).

# ---------------------------------------------------------------------------
# Smoothing models (same start values and error definition as stats::HoltWinters)
# ---------------------------------------------------------------------------
ses_fit <- function(y, alpha) {
  n <- length(y)
  level <- numeric(n)
  fitted_values <- rep(NA_real_, n)
  level[1] <- y[1]
  for (t in 2:n) {
    fitted_values[t] <- level[t - 1]
    level[t] <- alpha * y[t] + (1 - alpha) * level[t - 1]
  }
  list(level = level, fitted = fitted_values, sse = sum((y - fitted_values)[-1]^2))
}

holt_fit <- function(y, alpha, beta) {
  n <- length(y)
  level <- numeric(n)
  trend <- numeric(n)
  fitted_values <- rep(NA_real_, n)
  level[2] <- y[2]
  trend[2] <- y[2] - y[1]
  for (t in 3:n) {
    fitted_values[t] <- level[t - 1] + trend[t - 1]
    level[t] <- alpha * y[t] + (1 - alpha) * (level[t - 1] + trend[t - 1])
    trend[t] <- beta * (level[t] - level[t - 1]) + (1 - beta) * trend[t - 1]
  }
  list(level = level, trend = trend, fitted = fitted_values,
       sse = sum((y - fitted_values)[-(1:2)]^2))
}

# ---------------------------------------------------------------------------
# Forecasting methods. Each fit_* function returns a list with
#   name, params, fitted (one-step-ahead values), sigma, predict(h, level)
# ---------------------------------------------------------------------------
normal_interval <- function(point, sigma, multiplier, level) {
  z <- qnorm(1 - (1 - level) / 2)
  data.frame(forecast = point, lower = point - z * sigma * multiplier,
             upper = point + z * sigma * multiplier)
}

make_fit <- function(name, params, y, fitted_values, point_forecast, multiplier) {
  sigma <- sd(y - fitted_values, na.rm = TRUE)
  list(name = name, params = params, fitted = fitted_values, sigma = sigma,
       predict = function(h, level = 0.95) {
         normal_interval(point_forecast(h), sigma, vapply(seq_len(h), multiplier, numeric(1)), level)
       })
}

fit_naive <- function(y) {
  make_fit("Naive", "", y, c(NA, head(y, -1)),
           function(h) rep(tail(y, 1), h), function(h) sqrt(h))
}

fit_seasonal_naive <- function(y, m) {
  n <- length(y)
  fitted_values <- c(rep(NA_real_, m), y[seq_len(n - m)])
  make_fit("Seasonal naive", sprintf("period %d", m), y, fitted_values,
           function(h) y[n - m + ((seq_len(h) - 1) %% m) + 1],
           function(h) sqrt(floor((h - 1) / m) + 1))
}

fit_trend <- function(y) {
  t <- seq_along(y)
  model <- lm(y ~ t)
  fit <- list(name = "Linear trend", params = sprintf("slope %.4g per period", coef(model)[2]),
              fitted = unname(fitted(model)), sigma = summary(model)$sigma)
  fit$predict <- function(h, level = 0.95) {
    p <- predict(model, data.frame(t = length(y) + seq_len(h)), interval = "prediction", level = level)
    data.frame(forecast = p[, "fit"], lower = p[, "lwr"], upper = p[, "upr"], row.names = NULL)
  }
  fit
}

fit_moving_average <- function(y, w) {
  n <- length(y)
  w <- min(w, n - 2)
  fitted_values <- rep(NA_real_, n)
  for (t in (w + 1):n) fitted_values[t] <- mean(y[(t - w):(t - 1)])
  make_fit(sprintf("Moving average (%d)", w), "", y, fitted_values,
           function(h) rep(mean(tail(y, w)), h), function(h) sqrt(1 + 1 / w))
}

fit_ses <- function(y) {
  alpha <- optimize(function(a) ses_fit(y, a)$sse, c(0, 1))$minimum
  fit <- ses_fit(y, alpha)
  make_fit("Exponential smoothing", sprintf("alpha %.3f", alpha), y, fit$fitted,
           function(h) rep(tail(fit$level, 1), h),
           function(h) sqrt(1 + (h - 1) * alpha^2))
}

fit_holt <- function(y) {
  opt <- optim(c(0.3, 0.1), function(p) holt_fit(y, p[1], p[2])$sse, method = "L-BFGS-B",
               lower = c(0, 0), upper = c(1, 1))
  alpha <- opt$par[1]
  beta <- opt$par[2]
  fit <- holt_fit(y, alpha, beta)
  n <- length(y)
  make_fit("Holt linear trend", sprintf("alpha %.3f, beta %.3f", alpha, beta), y, fit$fitted,
           function(h) fit$level[n] + seq_len(h) * fit$trend[n],
           function(h) {
             j <- seq_len(h - 1)
             sqrt(1 + sum((alpha * (1 + j * beta))^2))
           })
}

fit_holt_winters <- function(y, m) {
  n <- length(y)
  if (n < 2 * m + 2) stop("Too short for Holt-Winters.")
  hw <- HoltWinters(ts(y, frequency = m), seasonal = "additive")
  fitted_values <- c(rep(NA_real_, m), as.numeric(fitted(hw)[, "xhat"]))
  fit <- list(name = "Holt-Winters (additive)",
              params = sprintf("alpha %.3f, beta %.3f, gamma %.3f", hw$alpha, hw$beta, hw$gamma),
              fitted = fitted_values, sigma = sd(y - fitted_values, na.rm = TRUE))
  fit$predict <- function(h, level = 0.95) {
    p <- predict(hw, n.ahead = h, prediction.interval = TRUE, level = level)
    data.frame(forecast = as.numeric(p[, "fit"]), lower = as.numeric(p[, "lwr"]),
               upper = as.numeric(p[, "upr"]))
  }
  fit
}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
accuracy_row <- function(actual, predicted) {
  e <- actual - predicted
  data.frame(rmse = sqrt(mean(e^2)), mae = mean(abs(e)),
             mape = if (all(actual != 0)) mean(abs(e / actual)) * 100 else NA_real_)
}

# Orders the rows by the time column when it is numeric or looks like a date.
order_by_time <- function(time_values) {
  if (is.numeric(time_values)) {
    return(order(time_values))
  }
  parsed <- tryCatch(as.Date(as.character(time_values)), error = function(e) NULL)
  if (!is.null(parsed) && !anyNA(parsed)) order(parsed) else seq_along(time_values)
}

# ---------------------------------------------------------------------------
# Main function
# ---------------------------------------------------------------------------
time_series_analysis <- function(df, value, time = NULL, horizon = 6, holdout = NULL,
                                 season_length = NULL, ma_window = 3, out_dir = NULL) {
  if (!is.numeric(df[[value]])) {
    stop("The value column must be numeric.", call. = FALSE)
  }

  ord <- if (is.null(time)) seq_len(nrow(df)) else order_by_time(df[[time]])
  y <- df[[value]][ord]
  time_labels <- if (is.null(time)) as.character(seq_along(y)) else as.character(df[[time]][ord])

  n_missing <- sum(is.na(y))
  if (n_missing > 0) {
    y <- approx(seq_along(y), y, xout = seq_along(y), rule = 2)$y
  }
  n <- length(y)
  if (n < 10) {
    stop("At least 10 observations are needed.", call. = FALSE)
  }
  horizon <- max(1, as.integer(horizon))

  m <- if (is.null(season_length)) NULL else as.integer(season_length)
  if (!is.null(m) && (m < 2 || n < 2 * m + 2)) {
    cat("Note: the series is too short for the given seasonal period; seasonal methods are skipped.\n")
    m <- NULL
  }

  test_size <- if (is.null(holdout)) max(3, min(round(0.2 * n), 24)) else as.integer(holdout)
  test_size <- max(2, min(test_size, n - 8))

  section(sprintf("Time series analysis of %s (n = %d)", value, n))
  if (n_missing > 0) {
    cat(sprintf("%d missing value(s) were filled by linear interpolation.\n", n_missing))
  }
  cat("Rows are assumed to be in chronological order",
      if (!is.null(time)) sprintf("(sorted by %s)", time) else "", "\n")
  cat(sprintf("Holdout period for comparing methods: the last %d observations\n", test_size))

  builders <- list(
    function(s) fit_naive(s),
    function(s) fit_trend(s),
    function(s) fit_moving_average(s, ma_window),
    function(s) fit_ses(s),
    function(s) fit_holt(s)
  )
  if (!is.null(m)) {
    builders <- c(builders, list(function(s) fit_seasonal_naive(s, m),
                                 function(s) fit_holt_winters(s, m)))
  }

  # Compare the methods on the holdout period.
  train <- y[seq_len(n - test_size)]
  test <- y[(n - test_size + 1):n]
  comparison <- do.call(rbind, lapply(builders, function(build) {
    fit <- tryCatch(build(train), error = function(e) NULL)
    if (is.null(fit)) {
      return(NULL)
    }
    cbind(method = fit$name, parameters = fit$params,
          accuracy_row(test, fit$predict(test_size)$forecast))
  }))
  comparison <- comparison[order(comparison$rmse), ]
  rownames(comparison) <- NULL
  names(comparison)[3:5] <- c("holdout_rmse", "holdout_mae", "holdout_mape_pct")

  cat("\nMethods ranked by holdout RMSE (parameters from the training part):\n")
  print(comparison, digits = 4, row.names = FALSE)
  best_name <- comparison$method[1]
  cat(sprintf("\nBest method on the holdout period: %s\n", best_name))
  if (test_size < 6) {
    cat("The holdout period is short, so this ranking is uncertain.\n")
  }

  # Refit everything on the full series.
  full_fits <- Filter(Negate(is.null), lapply(builders, function(build) {
    tryCatch(build(y), error = function(e) NULL)
  }))
  names(full_fits) <- vapply(full_fits, function(f) f$name, character(1))
  best <- full_fits[[best_name]]
  cat(sprintf("Refitted on all data: %s %s\n", best$name,
              if (nchar(best$params) > 0) sprintf("(%s)", best$params) else ""))

  residuals_best <- (y - best$fitted)
  residuals_best <- residuals_best[!is.na(residuals_best)]
  lag <- max(1, min(10, floor(length(residuals_best) / 5)))
  lb <- Box.test(residuals_best, lag = lag, type = "Ljung-Box")
  cat(sprintf("Ljung-Box test of residual autocorrelation (lag %d): p = %s %s\n", lag,
              format_p(lb$p.value),
              if (lb$p.value < 0.05) "(residuals are still autocorrelated; the model may be missing structure)" else "(no evidence of leftover autocorrelation)"))
  if (lb$p.value < 0.05 && !is.null(m)) {
    cat("Hint: if the seasonal swings grow as the level rises, analyse the logarithm of the series instead.\n")
  }
  cat(sprintf("In-sample one-step RMSE = %.4f\n", sqrt(mean(residuals_best^2))))

  forecast_table <- best$predict(horizon, 0.95)
  periods <- paste0("+", seq_len(horizon))
  cat(sprintf("\nForecast for the next %d periods (%s, approximate 95%% intervals):\n", horizon, best$name))
  print(cbind(period = periods, round(forecast_table, 4)), row.names = FALSE)

  if (length(full_fits) > 1) {
    cat("\nPoint forecasts of all methods (for comparison):\n")
    all_forecasts <- sapply(full_fits, function(f) f$predict(horizon, 0.95)$forecast)
    print(cbind(period = periods, as.data.frame(round(all_forecasts, 3))), row.names = FALSE)
  }

  if (!is.null(m)) {
    decomposed <- tryCatch(decompose(ts(y, frequency = m)), error = function(e) NULL)
    if (!is.null(decomposed)) {
      remainder <- decomposed$random[!is.na(decomposed$random)]
      deseasonalized <- (decomposed$x - decomposed$seasonal)[!is.na(decomposed$random)]
      seasonal_strength <- max(0, 1 - var(remainder) / var(decomposed$seasonal[!is.na(decomposed$random)] + remainder))
      cat(sprintf("\nSeasonal strength (0 to 1): %.3f\n", seasonal_strength))
      cat("Seasonal effects by position in the cycle:\n")
      print(round(decomposed$figure, 3))
    }
  }

  tick_label <- function(at) ifelse(at <= n, time_labels[pmin(at, n)], paste0("+", at - n))
  draw <- function() {
    old <- par(no.readonly = TRUE)
    on.exit(par(old))
    layout(matrix(c(1, 1, 2, 3), 2, byrow = TRUE))

    par(mar = c(4.5, 4.5, 3, 1))
    total <- n + horizon
    plot(NULL, xlim = c(1, total), xaxt = "n", xlab = if (is.null(time)) "Period" else time,
         ylab = value, ylim = range(y, forecast_table$lower, forecast_table$upper, best$fitted, na.rm = TRUE),
         main = sprintf("%s: observed, fitted and forecast (%s)", value, best$name))
    ticks <- unique(round(seq(1, total, length.out = min(total, 9))))
    axis(1, at = ticks, labels = tick_label(ticks))
    future <- n + seq_len(horizon)
    polygon(c(future, rev(future)), c(forecast_table$lower, rev(forecast_table$upper)),
            col = adjustcolor("red", 0.15), border = NA)
    lines(seq_len(n), y, lwd = 2)
    points(seq_len(n), y, pch = 19, cex = 0.5)
    lines(seq_len(n), best$fitted, col = "steelblue", lwd = 2)
    lines(c(n, future), c(y[n], forecast_table$forecast), col = "red", lwd = 2)
    points(future, forecast_table$forecast, pch = 19, col = "red", cex = 0.7)
    abline(v = n + 0.5, lty = 3, col = "gray50")
    legend("topleft", bg = "white", cex = 0.85, lwd = 2, col = c("black", "steelblue", "red"),
           legend = c("Observed", "Fitted (one step ahead)", "Forecast with 95% interval"))
    grid()

    par(mar = c(4.5, 10, 3, 1))
    ranked <- comparison[order(-comparison$holdout_rmse), ]
    barplot(ranked$holdout_rmse, names.arg = ranked$method, horiz = TRUE, las = 1, cex.names = 0.8,
            col = ifelse(ranked$method == best_name, "#fb6a4a", "#9ecae1"),
            xlab = "Holdout RMSE (lower is better)", main = "Method comparison")

    par(mar = c(4.5, 4.5, 3, 1))
    acf(residuals_best, main = "Residual autocorrelation", lag.max = lag + 5)
  }
  render_plot(draw, out_file(out_dir, "time_series_forecast.png"), width = 1400, height = 950)
  save_table(comparison, out_dir, "time_series_method_comparison.csv")
  save_table(cbind(period = periods, forecast_table), out_dir, "time_series_forecast.csv")

  invisible(list(comparison = comparison, best = best, forecast = forecast_table,
                 fits = full_fits, ljung_box = lb))
}
