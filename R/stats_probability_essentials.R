# ==============================================================================
# Statistics and Probability Essentials in R
# Base R only (no extra packages). Tested on R 4.3.3.
# Every section is self-contained; run the whole file or one section at a time.
# ==============================================================================

section <- function(title) cat("\n==== ", title, " ====\n", sep = "")
set.seed(123)   # makes all random results reproducible

# ------------------------------------------------------------------------------
section("1. Descriptive statistics")
# ------------------------------------------------------------------------------
x <- mtcars$mpg
mean(x); median(x); sd(x); var(x)
range(x); IQR(x); diff(range(x))
quantile(x, probs = c(0.05, 0.25, 0.5, 0.75, 0.95))
summary(x)

# Mode (R has no built-in function for the statistical mode)
stat_mode <- function(v) {
  tab <- table(v)
  as.numeric(names(tab)[tab == max(tab)])
}
stat_mode(mtcars$cyl)

# Coefficient of variation, standard error, skewness and kurtosis (by hand)
cv  <- sd(x) / mean(x)
se  <- sd(x) / sqrt(length(x))
skew <- mean((x - mean(x))^3) / sd(x)^3
kurt <- mean((x - mean(x))^4) / sd(x)^4 - 3     # excess kurtosis (approximate)
round(c(cv = cv, se = se, skewness = skew, excess_kurtosis = kurt), 3)

# Grouped statistics
tapply(mtcars$mpg, mtcars$cyl, mean)
aggregate(mpg ~ cyl, data = mtcars, FUN = function(v) c(mean = mean(v), sd = sd(v)))

# Outliers with the 1.5 * IQR rule
q <- quantile(x, c(0.25, 0.75))
fence <- c(q[1] - 1.5 * IQR(x), q[2] + 1.5 * IQR(x))
x[x < fence[1] | x > fence[2]]

# Standardization (z-scores)
z <- (x - mean(x)) / sd(x)
round(head(z), 3)
round(head(scale(x)[, 1]), 3)   # same result with scale()

# ------------------------------------------------------------------------------
section("2. Counting and basic probability")
# ------------------------------------------------------------------------------
factorial(5)                    # 5!
choose(10, 3)                   # combinations: C(10, 3)
factorial(10) / factorial(10 - 3)   # permutations: P(10, 3)

# Probability of at least one six in four rolls of a die
1 - (5 / 6)^4

# Random sampling
sample(1:6, 10, replace = TRUE)             # ten die rolls
sample(1:49, 6)                             # lottery draw, no replacement
sample(c("H", "T"), 10, replace = TRUE, prob = c(0.7, 0.3))   # biased coin

# Empirical probability by simulation
rolls <- sample(1:6, 100000, replace = TRUE)
mean(rolls == 6)                            # close to 1/6 = 0.1667

# Conditional probability from a table: P(am = 1 | cyl = 4)
tab <- table(mtcars$cyl, mtcars$am)
tab
prop.table(tab, margin = 1)                 # row proportions = P(am | cyl)

# Bayes theorem: disease test example
prevalence  <- 0.01       # P(D)
sensitivity <- 0.95       # P(+ | D)
specificity <- 0.90       # P(- | no D)
p_pos <- sensitivity * prevalence + (1 - specificity) * (1 - prevalence)
p_disease_given_pos <- sensitivity * prevalence / p_pos
round(p_disease_given_pos, 4)               # about 0.0876

# ------------------------------------------------------------------------------
section("3. Probability distributions (d, p, q, r functions)")
# ------------------------------------------------------------------------------
# d = density / mass, p = cumulative probability, q = quantile, r = random draws

# Binomial: 10 trials, success probability 0.3
dbinom(3, size = 10, prob = 0.3)            # P(X = 3)
pbinom(3, size = 10, prob = 0.3)            # P(X <= 3)
1 - pbinom(3, size = 10, prob = 0.3)        # P(X > 3)
qbinom(0.5, size = 10, prob = 0.3)          # median
10 * 0.3; sqrt(10 * 0.3 * 0.7)              # mean and sd

# Poisson: average rate 4 events per interval
dpois(2, lambda = 4)
ppois(2, lambda = 4)
1 - ppois(6, lambda = 4)

# Normal
dnorm(0)                                    # density at 0
pnorm(1.96)                                 # P(Z <= 1.96)
pnorm(110, mean = 100, sd = 15) - pnorm(90, mean = 100, sd = 15)
qnorm(c(0.025, 0.975))                      # critical values
qnorm(0.95, mean = 100, sd = 15)            # 95th percentile of N(100, 15)

# Uniform and exponential
punif(0.3, min = 0, max = 1)
pexp(2, rate = 0.5)                         # P(T <= 2), mean wait = 1/rate = 2
qexp(0.5, rate = 0.5)                       # median waiting time

# t, chi-squared and F quantiles (critical values)
qt(0.975, df = 20)
qchisq(0.95, df = 3)
qf(0.95, df1 = 2, df2 = 27)

# Random draws
round(rnorm(5, mean = 50, sd = 10), 2)
rbinom(5, size = 10, prob = 0.5)
rpois(5, lambda = 3)
round(runif(3, min = 0, max = 100), 2)
round(rexp(3, rate = 1), 3)

# ------------------------------------------------------------------------------
section("4. Law of large numbers and central limit theorem")
# ------------------------------------------------------------------------------
# Law of large numbers: the running mean converges to the true mean
flips <- rbinom(10000, 1, 0.5)
running_mean <- cumsum(flips) / seq_along(flips)
round(running_mean[c(10, 100, 1000, 10000)], 4)

# Central limit theorem: means of skewed (exponential) samples look normal
sample_means <- replicate(5000, mean(rexp(30, rate = 1)))
round(c(mean = mean(sample_means), sd = sd(sample_means)), 4)
# Theory: mean = 1, sd = 1 / sqrt(30) = 0.1826
round(skew <- mean((sample_means - mean(sample_means))^3) / sd(sample_means)^3, 3)

# Monte Carlo estimate of pi
n <- 100000
px <- runif(n); py <- runif(n)
4 * mean(px^2 + py^2 <= 1)

# ------------------------------------------------------------------------------
section("5. Confidence intervals")
# ------------------------------------------------------------------------------
# Mean (t-based)
t.test(x)$conf.int

# Manual 95 percent interval for the mean
m <- mean(x); s <- sd(x); n <- length(x)
m + c(-1, 1) * qt(0.975, df = n - 1) * s / sqrt(n)

# Proportion: 45 successes out of 120
prop.test(45, 120)$conf.int
binom.test(45, 120)$conf.int                # exact interval

# Variance (chi-squared based)
(n - 1) * s^2 / qchisq(c(0.975, 0.025), df = n - 1)

# ------------------------------------------------------------------------------
section("6. Hypothesis tests")
# ------------------------------------------------------------------------------
# Convention: reject H0 when p-value < alpha (usually 0.05)

# One-sample t-test: is the mean mpg equal to 20?
t.test(x, mu = 20)

# Two-sample t-test (Welch): manual vs automatic transmission
t.test(mpg ~ am, data = mtcars)
t.test(mpg ~ am, data = mtcars, var.equal = TRUE)   # classic Student version

# Paired t-test: before and after measurements
before <- c(200, 190, 210, 220, 205, 215, 198, 207)
after  <- c(195, 188, 203, 214, 200, 210, 196, 199)
t.test(before, after, paired = TRUE)

# Variance comparison and normality check
var.test(mpg ~ am, data = mtcars)
shapiro.test(mtcars$mpg)                    # H0: data are normal

# Non-parametric alternatives (no normality assumption)
suppressWarnings(wilcox.test(mpg ~ am, data = mtcars))
kruskal.test(mpg ~ factor(cyl), data = mtcars)

# Tests for proportions
binom.test(7, 20, p = 0.5)                  # exact test, one proportion
prop.test(c(45, 60), c(100, 100))           # two proportions

# Chi-squared test of independence and goodness of fit
hair_eye <- margin.table(HairEyeColor, c(1, 2))
chisq.test(hair_eye)
chisq.test(c(18, 22, 20, 40), p = c(0.25, 0.25, 0.25, 0.25))   # fit to uniform
fisher.test(matrix(c(3, 1, 1, 3), nrow = 2))                  # small counts

# Effect size for the two-group comparison (Cohen's d, pooled sd)
g1 <- mtcars$mpg[mtcars$am == 0]; g2 <- mtcars$mpg[mtcars$am == 1]
sp <- sqrt(((length(g1) - 1) * var(g1) + (length(g2) - 1) * var(g2)) /
             (length(g1) + length(g2) - 2))
round((mean(g2) - mean(g1)) / sp, 3)

# Multiple testing correction
p_values <- c(0.01, 0.04, 0.03, 0.20, 0.005)
round(p.adjust(p_values, method = "bonferroni"), 4)
round(p.adjust(p_values, method = "holm"), 4)
round(p.adjust(p_values, method = "BH"), 4)  # false discovery rate

# Power analysis
power.t.test(delta = 5, sd = 6, sig.level = 0.05, power = 0.8)   # sample size
power.t.test(n = 20, delta = 5, sd = 6, sig.level = 0.05)        # power

# ------------------------------------------------------------------------------
section("7. Analysis of variance (ANOVA)")
# ------------------------------------------------------------------------------
fit_aov <- aov(len ~ factor(dose), data = ToothGrowth)
summary(fit_aov)
TukeyHSD(fit_aov)                           # which pairs of groups differ

# Two-way ANOVA with interaction
summary(aov(len ~ supp * factor(dose), data = ToothGrowth))

# ------------------------------------------------------------------------------
section("8. Correlation")
# ------------------------------------------------------------------------------
cor(mtcars$mpg, mtcars$wt)                          # Pearson
cor(mtcars$mpg, mtcars$wt, method = "spearman")     # rank-based
cor(mtcars$mpg, mtcars$wt, method = "kendall")
cor.test(mtcars$mpg, mtcars$wt)
round(cor(mtcars[, c("mpg", "wt", "hp", "disp")]), 2)   # correlation matrix
round(cov(mtcars$mpg, mtcars$wt), 3)                    # covariance

# ------------------------------------------------------------------------------
section("9. Linear regression")
# ------------------------------------------------------------------------------
fit <- lm(mpg ~ wt + hp, data = mtcars)
summary(fit)
round(coef(fit), 4)
round(confint(fit), 3)

# Prediction with confidence and prediction intervals
new_car <- data.frame(wt = 3, hp = 120)
predict(fit, new_car, interval = "confidence")
predict(fit, new_car, interval = "prediction")

# Compare nested models
fit_small <- lm(mpg ~ wt, data = mtcars)
anova(fit_small, fit)
AIC(fit_small, fit)
BIC(fit_small, fit)

# Diagnostics: residual normality, constant variance, influential points
shapiro.test(residuals(fit))
round(head(sort(cooks.distance(fit), decreasing = TRUE), 3), 3)
round(head(hatvalues(fit), 3), 3)

# Logistic regression: probability of a manual transmission
logit <- glm(am ~ wt, data = mtcars, family = binomial)
round(coef(summary(logit)), 4)
round(exp(coef(logit)), 4)                          # odds ratios
predict(logit, data.frame(wt = 3), type = "response")

# ------------------------------------------------------------------------------
section("10. Bootstrap and permutation tests")
# ------------------------------------------------------------------------------
# Bootstrap confidence interval for the median
boot_medians <- replicate(5000, median(sample(x, replace = TRUE)))
quantile(boot_medians, c(0.025, 0.975))

# Bootstrap standard error of the mean
sd(replicate(5000, mean(sample(x, replace = TRUE))))
sd(x) / sqrt(length(x))                             # compare with the formula

# Permutation test for a difference in means
obs_diff <- mean(g2) - mean(g1)
all_vals <- c(g1, g2)
perm_diffs <- replicate(5000, {
  idx <- sample(length(all_vals), length(g2))
  mean(all_vals[idx]) - mean(all_vals[-idx])
})
mean(abs(perm_diffs) >= abs(obs_diff))              # two-sided p-value

# ------------------------------------------------------------------------------
section("11. Markov chain and expected value")
# ------------------------------------------------------------------------------
# Expected value and variance of a discrete distribution
values <- c(1, 2, 3, 4)
probs  <- c(0.1, 0.2, 0.3, 0.4)
ev <- sum(values * probs)
vr <- sum((values - ev)^2 * probs)
c(expected = ev, variance = vr)

# Two-state Markov chain: stationary distribution by repeated multiplication
P <- matrix(c(0.9, 0.1,
              0.5, 0.5), nrow = 2, byrow = TRUE)
state <- c(1, 0)
for (i in 1:50) state <- state %*% P
round(state, 4)                                     # about (0.8333, 0.1667)

cat("\nDone: all sections ran without errors.\n")
