# descriptive.R
# Descriptive statistics and correlation analysis (base R only).
# Requires helpers.R.
#
# Main functions
#   describe_data(df, columns)
#   correlation_analysis(df, columns, method = "pearson", out_dir = NULL)

skewness <- function(x) {
  x <- x[!is.na(x)]
  centered <- x - mean(x)
  variance <- mean(centered^2)
  if (variance == 0) NA_real_ else mean(centered^3) / variance^1.5
}

# Summary table for numeric columns, plus a short note on other columns.
describe_data <- function(df, columns = numeric_columns(df)) {
  section("Descriptive statistics")

  rows <- lapply(columns, function(name) {
    x <- df[[name]]
    values <- x[!is.na(x)]
    q <- quantile(values, c(0.25, 0.5, 0.75), names = FALSE)
    data.frame(variable = name, n = length(values), missing = sum(is.na(x)),
               mean = mean(values), sd = sd(values), min = min(values),
               q1 = q[1], median = q[2], q3 = q[3], max = max(values),
               skewness = skewness(values))
  })
  table <- do.call(rbind, rows)
  print(table, digits = 4, row.names = FALSE)

  other <- setdiff(names(df), columns)
  if (length(other) > 0) {
    cat("\nOther (non-numeric or unselected) columns:\n")
    for (name in other) {
      values <- df[[name]][!is.na(df[[name]])]
      counts <- sort(table(values), decreasing = TRUE)
      cat(sprintf("  %s: %d distinct values, most frequent: %s (%d)\n",
                  name, length(counts), names(counts)[1], counts[[1]]))
    }
  }
  invisible(table)
}

# Correlation matrix with p-values, strong pairs and a heat map.
correlation_analysis <- function(df, columns = numeric_columns(df), method = "pearson",
                                 out_dir = NULL) {
  if (length(columns) < 2) {
    stop("Choose at least 2 numeric columns.", call. = FALSE)
  }
  section(sprintf("Correlation analysis (%s)", method))

  p <- length(columns)
  r <- matrix(NA_real_, p, p, dimnames = list(columns, columns))
  p_values <- r

  for (i in seq_len(p)) {
    for (j in seq_len(p)) {
      if (i == j) {
        r[i, j] <- 1
        p_values[i, j] <- 0
        next
      }
      a <- df[[columns[i]]]
      b <- df[[columns[j]]]
      ok <- !is.na(a) & !is.na(b)
      if (sum(ok) >= 3) {
        test <- tryCatch(suppressWarnings(cor.test(a[ok], b[ok], method = method)),
                         error = function(e) NULL)
        if (!is.null(test)) {
          r[i, j] <- unname(test$estimate)
          p_values[i, j] <- test$p.value
        }
      }
    }
  }

  cat("Correlation coefficients:\n")
  print(round(r, 3))

  upper <- which(upper.tri(r), arr.ind = TRUE)
  pairs_table <- data.frame(var1 = columns[upper[, 1]], var2 = columns[upper[, 2]],
                            r = r[upper], p_value = p_values[upper])
  pairs_table <- pairs_table[!is.na(pairs_table$r), , drop = FALSE]
  pairs_table <- pairs_table[order(-abs(pairs_table$r)), , drop = FALSE]
  rownames(pairs_table) <- NULL

  strong <- pairs_table[abs(pairs_table$r) >= 0.7, , drop = FALSE]
  if (nrow(strong) > 0) {
    cat("\nStrong correlations (|r| >= 0.7):\n")
    shown <- strong
    shown$p_value <- format_p(shown$p_value)
    print(shown, digits = 3, row.names = FALSE)
    cat("Strongly correlated predictors can cause multicollinearity in regression.\n")
  } else {
    cat("\nNo pair has |r| >= 0.7.\n")
  }

  draw_heatmap <- function() {
    old <- par(mar = c(9, 9, 3, 2))
    on.exit(par(old))
    colors <- colorRampPalette(c("#2166ac", "#f7f7f7", "#b2182b"))(101)
    image(seq_len(p), seq_len(p), t(r[p:1, , drop = FALSE]), col = colors,
          zlim = c(-1, 1), axes = FALSE, xlab = "", ylab = "")
    axis(1, at = seq_len(p), labels = columns, las = 2)
    axis(2, at = seq_len(p), labels = rev(columns), las = 2)
    for (i in seq_len(p)) {
      for (j in seq_len(p)) {
        text(j, p - i + 1, if (is.na(r[i, j])) "NA" else sprintf("%.2f", r[i, j]), cex = 0.8)
      }
    }
    box()
    title(sprintf("Correlation matrix (%s)", method))
  }
  render_plot(draw_heatmap, out_file(out_dir, "correlation_heatmap.png"))

  if (p <= 8) {
    draw_pairs <- function() {
      pairs(df[columns], pch = 19, cex = 0.7, col = adjustcolor("steelblue", 0.7),
            lower.panel = NULL, main = "Scatter plot matrix")
    }
    render_plot(draw_pairs, out_file(out_dir, "scatter_matrix.png"))
  }

  out <- list(r = r, p_values = p_values, pairs = pairs_table)
  if (!is.null(out_dir)) {
    save_table(cbind(variable = rownames(r), as.data.frame(r)), out_dir, "correlation_matrix.csv")
  }
  invisible(out)
}
