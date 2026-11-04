# ==============================================================================
# Sample Size Estimation for Means in R
# Base R only (no extra packages). Tested on R 4.3.3.
# Each function returns the required sample size rounded UP to a whole number.
# Every section is self-contained; run the whole file or one section at a time.
# ==============================================================================

section <- function(title) cat("\n==== ", title, " ====\n", sep = "")
set.seed(42)

# ------------------------------------------------------------------------------
section("1. Estimating a mean with a given precision (confidence interval)")
# ------------------------------------------------------------------------------
# Goal: the confidence interval should have half-width (margin of error) E.
# Inputs: sd = standard deviation (known or guessed), margin = E, conf = level.

# Known population sd: use the normal quantile.
n_mean_z <- function(sd, margin, conf = 0.95) {
  z <- qnorm(1 - (1 - conf) / 2)
  ceiling((z * sd / margin)^2)
}

# Unknown sd estimated from the sample: the t quantile depends on n, so search
# upward for the smallest n whose t-based half-width is within the margin.
# The z-based answer is a lower bound, so the search starts there.
n_mean_t <- function(sd, margin, conf = 0.95) {
  n <- max(2, n_mean_z(sd, margin, conf))
  while (qt(1 - (1 - conf) / 2, df = n - 1) * sd / sqrt(n) > margin) n <- n + 1
  n
}

n_mean_z(sd = 15, margin = 3)                    # (1.96 * 15 / 3)^2 = 96.04 -> 97
n_mean_t(sd = 15, margin = 3)                    # slightly larger than the z answer

# Margin expressed as a percentage of the mean (relative precision)
n_mean_relative <- function(mean, sd, rel_margin, conf = 0.95) {
  n_mean_t(sd = sd, margin = rel_margin * mean, conf = conf)
}
n_mean_relative(mean = 100, sd = 20, rel_margin = 0.05)    # within 5 percent of the mean

# Check: the achieved half-width at the computed n should not exceed the target
n <- n_mean_t(15, 3)
qt(0.975, n - 1) * 15 / sqrt(n)

# Table: required n for several margins and confidence levels (sd = 15)
margins <- c(1, 2, 3, 5)
levels  <- c(0.90, 0.95, 0.99)
tab <- sapply(levels, function(cl) sapply(margins, function(m) n_mean_t(15, m, cl)))
dimnames(tab) <- list(margin = margins, confidence = levels)
tab

# ------------------------------------------------------------------------------
section("2. Finite population correction")
# ------------------------------------------------------------------------------
# When sampling without replacement from a small population of size N,
# fewer observations are needed.
n_fpc <- function(n0, N) ceiling(n0 / (1 + (n0 - 1) / N))

n0 <- n_mean_z(sd = 15, margin = 3)              # infinite-population answer
c(n0 = n0,
  N_500 = n_fpc(n0, 500),
  N_200 = n_fpc(n0, 200),
  N_100 = n_fpc(n0, 100))

# ------------------------------------------------------------------------------
section("3. Choosing the standard deviation when it is unknown")
# ------------------------------------------------------------------------------
# Option A: the range rule of thumb, sd is roughly range / 4
sd_from_range <- function(lo, hi) (hi - lo) / 4
sd_from_range(40, 100)

# Option B: pilot study with m observations. Use an upper confidence limit of
# the sd so the final study is not underpowered by an unlucky small pilot.
sd_upper <- function(s, m, conf = 0.80) {
  s * sqrt((m - 1) / qchisq(1 - conf, df = m - 1))   # one-sided upper limit
}
pilot <- c(52, 61, 48, 55, 67, 59, 50, 63, 58, 54)
s <- sd(pilot); m <- length(pilot)
round(c(pilot_sd = s, upper_80 = sd_upper(s, m, 0.80), upper_95 = sd_upper(s, m, 0.95)), 2)
n_mean_t(sd = s, margin = 2)                          # using the raw pilot sd
n_mean_t(sd = sd_upper(s, m), margin = 2)             # using the cautious upper limit

# ------------------------------------------------------------------------------
section("4. One-sample test of a mean (H0: mu = mu0)")
# ------------------------------------------------------------------------------
# delta = difference you want to detect, sd = standard deviation,
# alpha = significance level, power = 1 - beta.

# Normal approximation formula: n = ((z_{1-a/2} + z_{1-b}) * sd / delta)^2
n_one_sample_z <- function(delta, sd, alpha = 0.05, power = 0.80, sided = 2) {
  za <- qnorm(1 - alpha / sided)
  zb <- qnorm(power)
  ceiling(((za + zb) * sd / delta)^2)
}
n_one_sample_z(delta = 5, sd = 12)

# Exact calculation with the t distribution (preferred): power.t.test
res <- power.t.test(delta = 5, sd = 12, sig.level = 0.05, power = 0.80,
                    type = "one.sample", alternative = "two.sided")
res
ceiling(res$n)

# One-sided alternative needs fewer observations
ceiling(power.t.test(delta = 5, sd = 12, power = 0.80,
                     type = "one.sample", alternative = "one.sided")$n)

# Power achieved with a given n
power.t.test(n = 40, delta = 5, sd = 12, type = "one.sample")$power

# Smallest detectable difference with a given n and power
power.t.test(n = 40, sd = 12, power = 0.80, type = "one.sample")$delta

# ------------------------------------------------------------------------------
section("5. Two independent groups")
# ------------------------------------------------------------------------------
# Equal group sizes: n is PER GROUP.
res2 <- power.t.test(delta = 5, sd = 6, sig.level = 0.05, power = 0.80)
res2
ceiling(res2$n)

# Normal approximation with an allocation ratio k = n2 / n1
n_two_sample <- function(delta, sd, alpha = 0.05, power = 0.80, k = 1) {
  za <- qnorm(1 - alpha / 2)
  zb <- qnorm(power)
  n1 <- ceiling((1 + 1 / k) * (sd * (za + zb) / delta)^2)
  c(n1 = n1, n2 = ceiling(k * n1), total = n1 + ceiling(k * n1))
}
n_two_sample(delta = 5, sd = 6, k = 1)
n_two_sample(delta = 5, sd = 6, k = 2)                # twice as many in group 2

# Different standard deviations in the two groups (Welch-type approximation)
n_two_sample_unequal_sd <- function(delta, sd1, sd2, alpha = 0.05, power = 0.80) {
  za <- qnorm(1 - alpha / 2); zb <- qnorm(power)
  n1 <- ceiling((sd1^2 + sd2^2) * ((za + zb) / delta)^2)   # equal n in both groups
  n1
}
n_two_sample_unequal_sd(delta = 5, sd1 = 6, sd2 = 9)

# Sample size to ESTIMATE the difference of two means with half-width E
n_diff_ci <- function(sd, margin, conf = 0.95) {
  z <- qnorm(1 - (1 - conf) / 2)
  ceiling(2 * (z * sd / margin)^2)                     # per group
}
n_diff_ci(sd = 6, margin = 2)

# ------------------------------------------------------------------------------
section("6. Paired design (before and after)")
# ------------------------------------------------------------------------------
# Use the standard deviation of the DIFFERENCES, not of the raw measurements.
# If both measurements have sd s and correlation r: sd_diff = s * sqrt(2 * (1 - r)).
sd_diff <- function(s, r) s * sqrt(2 * (1 - r))
sd_diff(s = 10, r = 0.6)

res_p <- power.t.test(delta = 3, sd = sd_diff(10, 0.6), power = 0.80, type = "paired")
res_p
ceiling(res_p$n)                                       # number of PAIRS

# Higher correlation between the paired measurements reduces the sample size
r_values <- c(0, 0.3, 0.6, 0.9)
sapply(r_values, function(r)
  ceiling(power.t.test(delta = 3, sd = sd_diff(10, r), power = 0.80, type = "paired")$n))

# ------------------------------------------------------------------------------
section("7. Non-inferiority and equivalence")
# ------------------------------------------------------------------------------
# Non-inferiority: new treatment is not worse than control by more than margin M.
# H0: mu_new - mu_control <= -M. true_diff is the assumed true difference.
n_noninferiority <- function(sd, margin, true_diff = 0, alpha = 0.025, power = 0.80) {
  ceiling(power.t.test(delta = true_diff + margin, sd = sd, sig.level = alpha * 2,
                       power = power, alternative = "one.sided")$n)
}
n_noninferiority(sd = 10, margin = 4)                  # per group, true difference 0

# Equivalence (two one-sided tests, TOST): normal approximation per group.
# Both bounds -M and +M must be rejected; true_diff must lie inside (-M, M).
n_equivalence <- function(sd, margin, true_diff = 0, alpha = 0.05, power = 0.80) {
  za <- qnorm(1 - alpha)
  zb <- qnorm(1 - (1 - power) / 2)
  ceiling(2 * sd^2 * (za + zb)^2 / (margin - abs(true_diff))^2)
}
n_equivalence(sd = 10, margin = 5)

# ------------------------------------------------------------------------------
section("8. More than two groups (one-way ANOVA)")
# ------------------------------------------------------------------------------
# between.var = variance of the group means, within.var = common within-group variance
means <- c(10, 12, 15)                                 # expected group means
within_sd <- 5
between_var <- var(means)
res_a <- power.anova.test(groups = 3, between.var = between_var,
                          within.var = within_sd^2, power = 0.80)
res_a
ceiling(res_a$n)                                       # per group

# Cohen's f effect size: f = sd(group means, population version) / within sd
f <- sqrt(mean((means - mean(means))^2)) / within_sd
round(f, 3)

# ------------------------------------------------------------------------------
section("9. Using standardized effect sizes (Cohen's d)")
# ------------------------------------------------------------------------------
# d = difference / sd. Conventional labels: 0.2 small, 0.5 medium, 0.8 large.
d_values <- c(small = 0.2, medium = 0.5, large = 0.8)
n_by_d <- sapply(d_values, function(d) ceiling(power.t.test(delta = d, sd = 1, power = 0.80)$n))
n_by_d                                                 # per group, two-sample test

# Grid: required n per group for several effect sizes and power levels
deltas <- c(2, 3, 4, 5, 6)
powers <- c(0.80, 0.90, 0.95)
grid <- sapply(powers, function(pw)
  sapply(deltas, function(dl) ceiling(power.t.test(delta = dl, sd = 6, power = pw)$n)))
dimnames(grid) <- list(delta = deltas, power = powers)
grid

# ------------------------------------------------------------------------------
section("10. Adjusting for dropout and non-response")
# ------------------------------------------------------------------------------
inflate <- function(n, dropout) ceiling(n / (1 - dropout))
n_needed <- ceiling(power.t.test(delta = 5, sd = 6, power = 0.80)$n)
c(completers = n_needed,
  dropout_10 = inflate(n_needed, 0.10),
  dropout_20 = inflate(n_needed, 0.20),
  dropout_30 = inflate(n_needed, 0.30))

# Survey with expected response rate
n_to_contact <- function(n_responses, response_rate) ceiling(n_responses / response_rate)
n_to_contact(n_mean_t(15, 3), response_rate = 0.60)

# ------------------------------------------------------------------------------
section("11. Verification by simulation")
# ------------------------------------------------------------------------------
# Simulated power: draw many datasets at the computed n and count rejections.
sim_power_two_sample <- function(n, delta, sd, nsim = 5000, alpha = 0.05) {
  mean(replicate(nsim, {
    a <- rnorm(n, 0, sd)
    b <- rnorm(n, delta, sd)
    t.test(a, b)$p.value < alpha
  }))
}
n_calc <- ceiling(power.t.test(delta = 5, sd = 6, power = 0.80)$n)
c(n_per_group = n_calc, simulated_power = sim_power_two_sample(n_calc, 5, 6))   # about 0.80

# Simulated coverage of the confidence interval at the computed n for a mean
n_ci <- n_mean_t(sd = 15, margin = 3)
half_widths <- replicate(5000, {
  x <- rnorm(n_ci, mean = 100, sd = 15)
  qt(0.975, n_ci - 1) * sd(x) / sqrt(n_ci)
})
c(n = n_ci, mean_half_width = mean(half_widths),
  share_within_target = mean(half_widths <= 3))        # sd is estimated, so not always <= 3

# ------------------------------------------------------------------------------
section("12. A single wrapper function")
# ------------------------------------------------------------------------------
sample_size_mean <- function(design = c("ci", "one_sample", "two_sample", "paired"),
                             sd, delta = NULL, margin = NULL,
                             alpha = 0.05, power = 0.80, dropout = 0) {
  design <- match.arg(design)
  n <- switch(design,
    ci         = n_mean_t(sd, margin, conf = 1 - alpha),
    one_sample = ceiling(power.t.test(delta = delta, sd = sd, sig.level = alpha,
                                      power = power, type = "one.sample")$n),
    two_sample = ceiling(power.t.test(delta = delta, sd = sd, sig.level = alpha,
                                      power = power)$n),
    paired     = ceiling(power.t.test(delta = delta, sd = sd, sig.level = alpha,
                                      power = power, type = "paired")$n))
  list(design = design, n = n, n_with_dropout = inflate(n, dropout))
}
str(sample_size_mean("ci", sd = 15, margin = 3, dropout = 0.10))
str(sample_size_mean("two_sample", sd = 6, delta = 5, dropout = 0.15))
str(sample_size_mean("paired", sd = 6, delta = 3))

cat("\nDone: all sections ran without errors.\n")
