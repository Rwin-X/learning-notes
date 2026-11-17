# hypothesis_tests.R
# Group comparisons and tests of association, each with assumption checks and
# effect sizes (base R only). Requires helpers.R.
#
# Main functions
#   compare_two_groups(df, value, group)       independent samples: Welch t-test, Mann-Whitney
#   compare_paired(df, before, after)          paired samples: paired t-test, Wilcoxon
#   compare_many_groups(df, value, group)      3+ groups: ANOVA, Welch ANOVA, Kruskal-Wallis, post-hoc
#   chi_square_independence(df, var1, var2)    two categorical variables

effect_size_label <- function(d) {
  d <- abs(d)
  if (d < 0.2) "negligible" else if (d < 0.5) "small" else if (d < 0.8) "medium" else "large"
}

# Brown-Forsythe test for equal variances (Levene's test using group medians).
brown_forsythe <- function(values, groups) {
  deviations <- abs(values - ave(values, groups, FUN = median))
  table <- anova(lm(deviations ~ groups))
  c(statistic = table$`F value`[1], p_value = table$`Pr(>F)`[1])
}

shapiro_p <- function(x) {
  if (length(x) < 3 || length(x) > 5000 || length(unique(x)) < 2) {
    return(NA_real_)
  }
  shapiro.test(x)$p.value
}

describe_groups <- function(values, groups) {
  do.call(rbind, lapply(levels(groups), function(level) {
    x <- values[groups == level]
    data.frame(group = level, n = length(x), mean = mean(x), sd = sd(x),
               median = median(x), min = min(x), max = max(x))
  }))
}

# ---------------------------------------------------------------------------
# Two independent groups
# ---------------------------------------------------------------------------
compare_two_groups <- function(df, value, group, out_dir = NULL) {
  data <- df[complete.cases(df[c(value, group)]), c(value, group)]
  if (!is.numeric(data[[value]])) {
    stop("The value column must be numeric.", call. = FALSE)
  }
  groups <- factor(data[[group]])
  if (nlevels(groups) != 2) {
    stop(sprintf("The group column must have exactly 2 groups (found %d).", nlevels(groups)),
         call. = FALSE)
  }
  values <- data[[value]]
  x1 <- values[groups == levels(groups)[1]]
  x2 <- values[groups == levels(groups)[2]]
  n1 <- length(x1)
  n2 <- length(x2)
  if (min(n1, n2) < 3) {
    stop("Each group needs at least 3 observations.", call. = FALSE)
  }

  section(sprintf("Comparing %s between 2 groups of %s", value, group))
  print(describe_groups(values, groups), digits = 4, row.names = FALSE)

  p_norm <- c(shapiro_p(x1), shapiro_p(x2))
  bf <- brown_forsythe(values, groups)
  cat("\nAssumption checks:\n")
  cat(sprintf("  Shapiro-Wilk normality p-values: %s = %s, %s = %s\n",
              levels(groups)[1], format_p(p_norm[1]), levels(groups)[2], format_p(p_norm[2])))
  cat(sprintf("  Brown-Forsythe equal variances: F = %.3f, p = %s\n", bf["statistic"],
              format_p(bf["p_value"])))

  welch <- t.test(x1, x2, var.equal = FALSE)
  student <- t.test(x1, x2, var.equal = TRUE)
  mann <- suppressWarnings(wilcox.test(x1, x2, conf.int = FALSE))

  tests <- data.frame(
    test = c("Welch t-test (recommended)", "Student t-test (equal variances)", "Mann-Whitney U"),
    statistic = c(unname(welch$statistic), unname(student$statistic), unname(mann$statistic)),
    df = c(unname(welch$parameter), unname(student$parameter), NA),
    p_value = c(welch$p.value, student$p.value, mann$p.value)
  )
  cat("\nTests of a difference between the groups:\n")
  shown <- tests
  shown$p_value <- format_p(shown$p_value)
  print(shown, digits = 4, row.names = FALSE)

  difference <- mean(x1) - mean(x2)
  cat(sprintf("\nMean difference (%s - %s) = %.4f, 95%% CI [%.4f, %.4f] (Welch)\n",
              levels(groups)[1], levels(groups)[2], difference, welch$conf.int[1], welch$conf.int[2]))

  pooled_sd <- sqrt(((n1 - 1) * var(x1) + (n2 - 1) * var(x2)) / (n1 + n2 - 2))
  cohen_d <- difference / pooled_sd
  hedges_g <- cohen_d * (1 - 3 / (4 * (n1 + n2) - 9))
  superiority <- unname(mann$statistic) / (n1 * n2)
  cat(sprintf("Effect sizes: Cohen's d = %.3f (%s), Hedges' g = %.3f\n", cohen_d,
              effect_size_label(cohen_d), hedges_g))
  cat(sprintf("Probability that a random %s observation exceeds a random %s one = %.3f\n",
              levels(groups)[1], levels(groups)[2], superiority))

  normal_ok <- all(is.na(p_norm) | p_norm > 0.05) || min(n1, n2) >= 30
  cat(sprintf("\nGuidance: %s\n", if (normal_ok) {
    "the groups look approximately normal (or are large), so the Welch t-test is appropriate."
  } else {
    "normality is doubtful in a small group; rely on the Mann-Whitney test or check for outliers."
  }))

  draw <- function() {
    boxplot(values ~ groups, col = c("#9ecae1", "#fcae91"), outline = FALSE, xlab = group,
            ylab = value, main = sprintf("%s by %s (Welch p = %s)", value, group, format_p(welch$p.value)))
    stripchart(values ~ groups, vertical = TRUE, method = "jitter", pch = 19, cex = 0.8,
               col = adjustcolor("gray25", 0.6), add = TRUE)
    points(1:2, c(mean(x1), mean(x2)), pch = 23, bg = "red", cex = 1.6)
    legend("topright", legend = "Group mean", pch = 23, pt.bg = "red", bty = "n", cex = 0.9)
  }
  render_plot(draw, out_file(out_dir, "two_group_comparison.png"), width = 1000, height = 750)
  save_table(tests, out_dir, "two_group_tests.csv")

  invisible(list(descriptives = describe_groups(values, groups), tests = tests, welch = welch,
                 cohen_d = cohen_d, hedges_g = hedges_g))
}

# ---------------------------------------------------------------------------
# Paired samples
# ---------------------------------------------------------------------------
compare_paired <- function(df, before, after, out_dir = NULL) {
  data <- df[complete.cases(df[c(before, after)]), c(before, after)]
  if (!is.numeric(data[[before]]) || !is.numeric(data[[after]])) {
    stop("Both columns must be numeric.", call. = FALSE)
  }
  x <- data[[before]]
  y <- data[[after]]
  differences <- y - x
  n <- length(differences)
  if (n < 3) {
    stop("At least 3 complete pairs are needed.", call. = FALSE)
  }

  section(sprintf("Paired comparison: %s -> %s (%d pairs)", before, after, n))
  cat(sprintf("%s: mean = %.4f, sd = %.4f\n", before, mean(x), sd(x)))
  cat(sprintf("%s: mean = %.4f, sd = %.4f\n", after, mean(y), sd(y)))
  cat(sprintf("Difference (%s - %s): mean = %.4f, sd = %.4f\n", after, before,
              mean(differences), sd(differences)))
  cat(sprintf("\nShapiro-Wilk on the differences: p = %s\n", format_p(shapiro_p(differences))))

  tt <- t.test(y, x, paired = TRUE)
  wt <- suppressWarnings(wilcox.test(y, x, paired = TRUE))
  tests <- data.frame(test = c("Paired t-test", "Wilcoxon signed-rank"),
                      statistic = c(unname(tt$statistic), unname(wt$statistic)),
                      df = c(unname(tt$parameter), NA), p_value = c(tt$p.value, wt$p.value))
  shown <- tests
  shown$p_value <- format_p(shown$p_value)
  cat("\n")
  print(shown, digits = 4, row.names = FALSE)
  cat(sprintf("\nMean difference = %.4f, 95%% CI [%.4f, %.4f]\n", mean(differences),
              tt$conf.int[1], tt$conf.int[2]))

  dz <- mean(differences) / sd(differences)
  cat(sprintf("Effect size (Cohen's d_z) = %.3f (%s)\n", dz, effect_size_label(dz)))
  cat(sprintf("Correlation between the two measurements: r = %.3f\n", cor(x, y)))

  draw <- function() {
    old <- par(mfrow = c(1, 2), mar = c(4.5, 4.5, 3, 1))
    on.exit(par(old))
    plot(NULL, xlim = c(0.7, 2.3), ylim = range(c(x, y)), xaxt = "n", xlab = "",
         ylab = "Value", main = "Each pair")
    axis(1, at = 1:2, labels = c(before, after))
    segments(1, x, 2, y, col = adjustcolor(ifelse(y >= x, "#2c7fb8", "#d95f0e"), 0.6))
    points(rep(1, n), x, pch = 19, col = "gray30")
    points(rep(2, n), y, pch = 19, col = "gray30")
    segments(1, mean(x), 2, mean(y), lwd = 4, col = "red")

    hist(differences, breaks = "Sturges", col = "#9ecae1", border = "white",
         xlab = sprintf("%s - %s", after, before), main = "Differences")
    abline(v = 0, lty = 2)
    abline(v = mean(differences), col = "red", lwd = 3)
  }
  render_plot(draw, out_file(out_dir, "paired_comparison.png"), width = 1300, height = 650)
  save_table(tests, out_dir, "paired_tests.csv")

  invisible(list(tests = tests, t_test = tt, cohen_dz = dz))
}

# ---------------------------------------------------------------------------
# Three or more groups
# ---------------------------------------------------------------------------
compare_many_groups <- function(df, value, group, out_dir = NULL) {
  data <- df[complete.cases(df[c(value, group)]), c(value, group)]
  if (!is.numeric(data[[value]])) {
    stop("The value column must be numeric.", call. = FALSE)
  }
  groups <- factor(data[[group]])
  k <- nlevels(groups)
  if (k < 3) {
    stop(sprintf("Found %d groups; use the two-group comparison for exactly 2.", k), call. = FALSE)
  }
  counts <- table(groups)
  if (any(counts < 2)) {
    stop("Each group needs at least 2 observations.", call. = FALSE)
  }
  values <- data[[value]]
  n <- length(values)
  dat <- data.frame(v = values, g = groups)

  section(sprintf("Comparing %s across %d groups of %s", value, k, group))
  print(describe_groups(values, groups), digits = 4, row.names = FALSE)

  fit <- aov(v ~ g, data = dat)
  anova_table <- summary(fit)[[1]]
  ss_between <- anova_table$`Sum Sq`[1]
  ss_within <- anova_table$`Sum Sq`[2]
  ms_within <- anova_table$`Mean Sq`[2]
  eta2 <- ss_between / (ss_between + ss_within)
  omega2 <- max(0, (ss_between - (k - 1) * ms_within) / (ss_between + ss_within + ms_within))

  bf <- brown_forsythe(values, groups)
  p_resid <- shapiro_p(residuals(fit))
  cat("\nAssumption checks:\n")
  cat(sprintf("  Shapiro-Wilk on ANOVA residuals: p = %s\n", format_p(p_resid)))
  cat(sprintf("  Brown-Forsythe equal variances: F = %.3f, p = %s\n", bf["statistic"],
              format_p(bf["p_value"])))

  welch <- oneway.test(v ~ g, data = dat, var.equal = FALSE)
  kruskal <- kruskal.test(v ~ g, data = dat)
  tests <- data.frame(
    test = c("One-way ANOVA", "Welch ANOVA (unequal variances)", "Kruskal-Wallis"),
    statistic = c(anova_table$`F value`[1], unname(welch$statistic), unname(kruskal$statistic)),
    df = c(anova_table$Df[1], unname(welch$parameter[1]), unname(kruskal$parameter)),
    p_value = c(anova_table$`Pr(>F)`[1], welch$p.value, kruskal$p.value)
  )
  cat("\nOverall tests (H0: all groups have the same mean / distribution):\n")
  shown <- tests
  shown$p_value <- format_p(shown$p_value)
  print(shown, digits = 4, row.names = FALSE)
  cat(sprintf("\nEffect size: eta-squared = %.3f, omega-squared = %.3f (share of variance explained by %s)\n",
              eta2, omega2, group))

  tukey <- TukeyHSD(fit)$g
  tukey_table <- data.frame(comparison = rownames(tukey), difference = tukey[, "diff"],
                            ci_low = tukey[, "lwr"], ci_high = tukey[, "upr"],
                            adjusted_p = tukey[, "p adj"], row.names = NULL)
  tukey_table <- tukey_table[order(tukey_table$adjusted_p), ]
  cat("\nPost-hoc comparisons (Tukey HSD, assumes equal variances):\n")
  shown <- tukey_table
  shown$adjusted_p <- format_p(shown$adjusted_p)
  print(shown, digits = 4, row.names = FALSE)

  pairwise <- pairwise.t.test(values, groups, pool.sd = FALSE, p.adjust.method = "holm")
  cat("\nPairwise Welch t-tests with Holm adjustment (robust to unequal variances), p-values:\n")
  print(round(pairwise$p.value, 4), na.print = "-")

  if (anova_table$`Pr(>F)`[1] >= 0.05) {
    cat("\nThe overall test is not significant, so post-hoc differences should be interpreted with caution.\n")
  }

  draw <- function() {
    old <- par(mfrow = c(1, 2), mar = c(5, 4.5, 3, 1))
    on.exit(par(old))
    boxplot(values ~ groups, col = "#9ecae1", outline = FALSE, xlab = group, ylab = value,
            main = sprintf("%s by %s (ANOVA p = %s)", value, group, format_p(anova_table$`Pr(>F)`[1])))
    stripchart(values ~ groups, vertical = TRUE, method = "jitter", pch = 19, cex = 0.7,
               col = adjustcolor("gray25", 0.6), add = TRUE)
    means <- tapply(values, groups, mean)
    points(seq_len(k), means, pch = 23, bg = "red", cex = 1.4)

    par(mar = c(4.5, 9, 3, 1))
    plot(TukeyHSD(fit), las = 1, cex.axis = 0.8)
  }
  render_plot(draw, out_file(out_dir, "group_comparison.png"), width = 1400, height = 700)
  save_table(tests, out_dir, "group_tests.csv")
  save_table(tukey_table, out_dir, "tukey_posthoc.csv")

  invisible(list(tests = tests, tukey = tukey_table, eta_squared = eta2, omega_squared = omega2))
}

# ---------------------------------------------------------------------------
# Two categorical variables
# ---------------------------------------------------------------------------
chi_square_independence <- function(df, var1, var2, out_dir = NULL, seed = 1) {
  data <- df[complete.cases(df[c(var1, var2)]), c(var1, var2)]
  f1 <- factor(data[[var1]])
  f2 <- factor(data[[var2]])
  if (nlevels(f1) < 2 || nlevels(f2) < 2) {
    stop("Each variable needs at least 2 categories.", call. = FALSE)
  }
  if (nlevels(f1) > 15 || nlevels(f2) > 15) {
    stop("Too many categories (limit 15 per variable). Choose categorical variables.", call. = FALSE)
  }

  tab <- table(f1, f2, dnn = c(var1, var2))
  n <- sum(tab)
  r <- nrow(tab)
  c <- ncol(tab)

  section(sprintf("Association between %s and %s (n = %d)", var1, var2, n))
  cat("Observed counts:\n")
  print(tab)
  cat("\nRow percentages:\n")
  print(round(100 * prop.table(tab, 1), 1))

  test <- suppressWarnings(chisq.test(tab, correct = FALSE))
  expected <- test$expected
  small_share <- mean(expected < 5)
  cat(sprintf("\nExpected counts: minimum = %.2f, %.0f%% of cells below 5\n",
              min(expected), 100 * small_share))

  cat(sprintf("Pearson chi-square test: chi-square = %.3f, df = %d, p = %s\n",
              test$statistic, test$parameter, format_p(test$p.value)))

  exact_p <- NA_real_
  if (r == 2 && c == 2) {
    yates <- suppressWarnings(chisq.test(tab, correct = TRUE))
    exact <- fisher.test(tab)
    exact_p <- exact$p.value
    cat(sprintf("With Yates continuity correction: chi-square = %.3f, p = %s\n",
                yates$statistic, format_p(yates$p.value)))
    cat(sprintf("Fisher exact test: p = %s, odds ratio = %.3f, 95%% CI [%.3f, %.3f]\n",
                format_p(exact$p.value), exact$estimate, exact$conf.int[1], exact$conf.int[2]))
  } else if (small_share > 0.2 || min(expected) < 1) {
    simulated <- with_seed(seed, chisq.test(tab, simulate.p.value = TRUE, B = 10000))
    exact_p <- simulated$p.value
    cat(sprintf("Monte Carlo p-value (10000 simulations, better for small counts): %s\n",
                format_p(exact_p)))
  }
  if (small_share > 0.2) {
    cat("Warning: more than 20% of expected counts are below 5, so the chi-square approximation may be unreliable.\n")
  }

  cramers_v <- sqrt(unname(test$statistic) / (n * min(r - 1, c - 1)))
  v_label <- if (cramers_v < 0.1) "negligible" else if (cramers_v < 0.3) "small" else if (cramers_v < 0.5) "medium" else "large"
  cat(sprintf("\nCramer's V = %.3f (%s association; rough guide)\n", cramers_v, v_label))

  residuals_table <- round(test$stdres, 2)
  cat("\nStandardized residuals (cells beyond +/-2 deviate notably from independence):\n")
  print(residuals_table)

  draw <- function() {
    old <- par(mfrow = c(1, 2), mar = c(4.5, 4.5, 3, 1))
    on.exit(par(old))
    mosaicplot(tab, shade = TRUE, main = "Mosaic plot", las = 1)
    barplot(t(prop.table(tab, 1)), beside = TRUE, col = rainbow(c, s = 0.4, v = 0.9),
            xlab = var1, ylab = "Proportion within row", main = "Row proportions",
            legend.text = colnames(tab), args.legend = list(title = var2, cex = 0.8, bty = "n"))
  }
  render_plot(draw, out_file(out_dir, "chi_square_association.png"), width = 1400, height = 650)

  summary_table <- data.frame(statistic = unname(test$statistic), df = unname(test$parameter),
                              p_value = test$p.value, exact_or_simulated_p = exact_p,
                              cramers_v = cramers_v)
  save_table(summary_table, out_dir, "chi_square_summary.csv")

  invisible(list(table = tab, test = test, cramers_v = cramers_v, stdres = test$stdres))
}
