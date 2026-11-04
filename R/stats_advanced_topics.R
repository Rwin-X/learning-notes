# ==============================================================================
# Advanced Statistics and Probability Topics in R
# Base R only (no extra packages). Tested on R 4.3.3.
# Companion to stats_probability_essentials.R.
# Every section is self-contained; run the whole file or one section at a time.
# ==============================================================================

section <- function(title) cat("\n==== ", title, " ====\n", sep = "")
set.seed(2024)   # makes all random results reproducible

# ------------------------------------------------------------------------------
section("1. Time series")
# ------------------------------------------------------------------------------
ap <- AirPassengers                      # monthly airline passengers, 1949-1960
class(ap); frequency(ap); start(ap); end(ap)
window(ap, start = c(1960, 1))           # extract a time window

# Decomposition into trend, seasonal and random parts
dec <- decompose(ap, type = "multiplicative")
round(dec$figure, 3)                     # seasonal index for each month

# Centered 12-month moving average (smooths out the seasonality)
ma12 <- stats::filter(ap, rep(1 / 12, 12), sides = 2)
round(window(ma12, start = c(1955, 1), end = c(1955, 6)), 1)

# Stationarity: log transform and first difference
d1 <- diff(log(ap))
round(acf(d1, plot = FALSE, lag.max = 6)$acf[-1, 1, 1], 3)    # autocorrelations
round(pacf(d1, plot = FALSE, lag.max = 6)$acf[, 1, 1], 3)     # partial autocorrelations
Box.test(d1, lag = 10, type = "Ljung-Box")                    # H0: no autocorrelation

# Seasonal ARIMA model (the classic "airline model") on the log scale
fit_ts <- arima(log(ap), order = c(0, 1, 1), seasonal = list(order = c(0, 1, 1), period = 12))
fit_ts
round(exp(predict(fit_ts, n.ahead = 6)$pred))                 # forecast, original scale

# Holt-Winters exponential smoothing
hw <- HoltWinters(ap, seasonal = "multiplicative")
round(unlist(hw[c("alpha", "beta", "gamma")]), 3)

# Honest accuracy check: train on 1949-1958, test on 1959-1960
train <- window(ap, end = c(1958, 12))
test  <- window(ap, start = c(1959, 1))
fit_tr <- arima(log(train), order = c(0, 1, 1), seasonal = list(order = c(0, 1, 1), period = 12))
pred <- exp(predict(fit_tr, n.ahead = length(test))$pred)
c(RMSE = sqrt(mean((test - pred)^2)), MAPE_percent = 100 * mean(abs(test - pred) / test))

# ------------------------------------------------------------------------------
section("2. Bayesian inference")
# ------------------------------------------------------------------------------
# Beta-binomial model: unknown success probability theta, 14 successes in 20 trials
successes <- 14; n <- 20
a0 <- 1; b0 <- 1                         # uniform Beta(1, 1) prior
a1 <- a0 + successes                     # conjugate update: posterior is Beta(a1, b1)
b1 <- b0 + n - successes
c(post_mean = a1 / (a1 + b1), post_sd = sqrt(a1 * b1 / ((a1 + b1)^2 * (a1 + b1 + 1))))
qbeta(c(0.025, 0.975), a1, b1)           # 95 percent credible interval

# Same posterior by grid approximation (works for any prior and likelihood)
grid  <- seq(0, 1, length.out = 1001)
post  <- dbeta(grid, a0, b0) * dbinom(successes, n, grid)
post  <- post / sum(post)
sum(grid * post)                         # posterior mean from the grid

# Monte Carlo summaries from posterior draws
draws <- rbeta(100000, a1, b1)
mean(draws > 0.5)                        # P(theta > 0.5 | data)
quantile(draws, c(0.025, 0.5, 0.975))

# Posterior predictive: successes in the next 10 trials
future <- rbinom(100000, size = 10, prob = draws)
round(table(future) / length(future), 3)

# Normal model with known sd: prior N(100, 15^2), data mean 108 from n = 25 (sd = 20)
mu0 <- 100; tau0 <- 15; xbar <- 108; sigma <- 20; n_obs <- 25
prec <- 1 / tau0^2 + n_obs / sigma^2                     # precisions add
post_mu <- (mu0 / tau0^2 + n_obs * xbar / sigma^2) / prec
round(c(post_mean = post_mu, post_sd = sqrt(1 / prec)), 3)

# Metropolis-Hastings sampler for the same beta-binomial posterior
log_post <- function(th) {
  if (th <= 0 || th >= 1) return(-Inf)
  dbinom(successes, n, th, log = TRUE) + dbeta(th, a0, b0, log = TRUE)
}
chain <- numeric(20000); chain[1] <- 0.5
for (i in 2:length(chain)) {
  proposal <- chain[i - 1] + rnorm(1, 0, 0.1)          # random-walk proposal
  accept <- log(runif(1)) < log_post(proposal) - log_post(chain[i - 1])
  chain[i] <- if (accept) proposal else chain[i - 1]
}
kept <- chain[-(1:2000)]                                # discard burn-in
round(c(mean = mean(kept), lower = quantile(kept, 0.025)[[1]],
        upper = quantile(kept, 0.975)[[1]]), 3)         # close to the exact answer

# ------------------------------------------------------------------------------
section("3. Multivariate methods")
# ------------------------------------------------------------------------------
# Simulate from a bivariate normal using the Cholesky factor
mu <- c(10, 20)
Sigma <- matrix(c(4, 2,
                  2, 3), nrow = 2, byrow = TRUE)
Z <- matrix(rnorm(2 * 20000), ncol = 2)
X <- sweep(Z %*% chol(Sigma), 2, mu, "+")
round(colMeans(X), 2)
round(cov(X), 2)                                        # close to Sigma

# Mahalanobis distance: distance that accounts for correlation
md2 <- mahalanobis(X, center = mu, cov = Sigma)
mean(md2 > qchisq(0.95, df = 2))                        # about 0.05

# Principal component analysis on standardized variables
pc <- prcomp(mtcars[, c("mpg", "disp", "hp", "wt")], scale. = TRUE)
summary(pc)
round(pc$rotation[, 1:2], 3)                            # loadings

# K-means and hierarchical clustering on iris measurements
meas <- scale(iris[, 1:4])
km <- kmeans(meas, centers = 3, nstart = 25)
table(cluster = km$cluster, species = iris$Species)
hc <- hclust(dist(meas), method = "ward.D2")
table(cluster = cutree(hc, k = 3), species = iris$Species)

# Multivariate test of group means is also available through manova()
summary(manova(cbind(Sepal.Length, Petal.Length) ~ Species, data = iris))

# ------------------------------------------------------------------------------
section("4. Generating random numbers from any distribution")
# ------------------------------------------------------------------------------
# Inverse transform sampling: exponential with rate 2
u <- runif(100000)
inv <- -log(1 - u) / 2
round(c(mean = mean(inv), theory = 1 / 2), 3)

# Box-Muller transform: two uniforms to standard normals
u1 <- runif(50000); u2 <- runif(50000)
bm <- sqrt(-2 * log(u1)) * cos(2 * pi * u2)
round(c(mean = mean(bm), sd = sd(bm)), 3)

# Rejection sampling for Beta(2, 5) using a uniform envelope
M <- dbeta(0.2, 2, 5)                                   # density maximum (mode = 0.2)
cand <- runif(100000)
keep <- runif(100000) < dbeta(cand, 2, 5) / M
acc <- cand[keep]
round(c(accept_rate = mean(keep), mean = mean(acc), theory = 2 / 7), 3)

# Normal approximation to the binomial with continuity correction
size <- 100; p <- 0.3
exact  <- pbinom(35, size, p)
approx <- pnorm(35.5, mean = size * p, sd = sqrt(size * p * (1 - p)))
round(c(exact = exact, normal_approx = approx), 4)

# ------------------------------------------------------------------------------
section("5. Maximum likelihood estimation")
# ------------------------------------------------------------------------------
# Fit a gamma distribution to simulated data with true shape = 3 and rate = 2
dat <- rgamma(500, shape = 3, rate = 2)
neg_loglik <- function(p) -sum(dgamma(dat, shape = p[1], rate = p[2], log = TRUE))
opt <- optim(c(1, 1), neg_loglik, method = "L-BFGS-B",
             lower = c(1e-3, 1e-3), hessian = TRUE)
round(opt$par, 3)                                       # MLE of (shape, rate)
round(sqrt(diag(solve(opt$hessian))), 3)                # standard errors

# Method of moments for comparison
m <- mean(dat); v <- var(dat)
round(c(shape = m^2 / v, rate = m / v), 3)

# Goodness of fit: Kolmogorov-Smirnov test against the fitted distribution
# (p-value is approximate because parameters were estimated from the same data)
ks.test(dat, "pgamma", shape = opt$par[1], rate = opt$par[2])

# Likelihood ratio test: does a Poisson model with a group effect fit better?
null_fit <- glm(count ~ 1, data = InsectSprays, family = poisson)
alt_fit  <- glm(count ~ spray, data = InsectSprays, family = poisson)
anova(null_fit, alt_fit, test = "Chisq")

# ------------------------------------------------------------------------------
section("6. Classic probability simulations")
# ------------------------------------------------------------------------------
# Monty Hall problem: stay versus switch
n_games <- 100000
prize <- sample(3, n_games, replace = TRUE)
pick  <- sample(3, n_games, replace = TRUE)
stay_wins <- mean(prize == pick)
round(c(stay = stay_wins, switch = 1 - stay_wins), 3)   # about 1/3 and 2/3

# Birthday problem: exact probability of a shared birthday among n people
birthday <- function(n) 1 - prod((365 - seq_len(n) + 1) / 365)
round(sapply(c(10, 23, 50), birthday), 4)
mean(replicate(20000, anyDuplicated(sample(365, 23, replace = TRUE)) > 0))   # simulation

# Random walk: position after 1000 fair +1/-1 steps
walk <- cumsum(sample(c(-1, 1), 1000, replace = TRUE))
c(final = walk[1000], max = max(walk), min = min(walk))

# Gambler's ruin: start with 10 units, win/lose 1 per bet, stop at 0 or 20
ruin <- function(start = 10, goal = 20, p = 0.5) {
  wealth <- start
  while (wealth > 0 && wealth < goal) wealth <- wealth + sample(c(-1, 1), 1, prob = c(1 - p, p))
  wealth == 0
}
mean(replicate(5000, ruin()))                           # theory: 0.5
mean(replicate(5000, ruin(p = 0.48)))                   # a slightly unfair game

# Expected number of rolls until the first six (geometric distribution)
mean(replicate(20000, which(sample(1:6, 100, replace = TRUE) == 6)[1]))   # theory: 6

# ------------------------------------------------------------------------------
section("7. Model validation: cross-validation")
# ------------------------------------------------------------------------------
k <- 5
folds <- sample(rep(1:k, length.out = nrow(mtcars)))     # random fold labels
cv_rmse <- function(formula) {
  errs <- sapply(1:k, function(i) {
    tr <- mtcars[folds != i, ]
    te <- mtcars[folds == i, ]
    fit <- lm(formula, data = tr)
    sqrt(mean((te$mpg - predict(fit, te))^2))
  })
  mean(errs)
}
round(c(wt = cv_rmse(mpg ~ wt),
        wt_hp = cv_rmse(mpg ~ wt + hp),
        all_vars = cv_rmse(mpg ~ .)), 3)                 # smaller is better

# Leave-one-out error for a linear model without refitting (hat-value shortcut)
fit <- lm(mpg ~ wt + hp, data = mtcars)
loo <- sqrt(mean((residuals(fit) / (1 - hatvalues(fit)))^2))
round(loo, 3)

# ------------------------------------------------------------------------------
section("8. Count models and nonlinear regression")
# ------------------------------------------------------------------------------
# Poisson regression for counts
pois <- glm(count ~ spray, data = InsectSprays, family = poisson)
round(coef(summary(pois)), 3)
round(exp(coef(pois)), 3)                               # rate ratios against spray A
deviance(pois) / df.residual(pois)                      # near 1 means no overdispersion

# Nonlinear least squares: mpg = a * exp(b * wt)
fit_nls <- nls(mpg ~ a * exp(b * wt), data = mtcars, start = list(a = 40, b = -0.3))
round(coef(fit_nls), 3)
round(summary(fit_nls)$sigma, 3)                        # residual standard error

# Smoothing without assuming a functional form
lo <- loess(mpg ~ wt, data = mtcars, span = 0.8)
round(predict(lo, data.frame(wt = c(2, 3, 4))), 2)

# ------------------------------------------------------------------------------
section("9. Empirical distributions and two-sample comparison")
# ------------------------------------------------------------------------------
s1 <- rnorm(80, mean = 0)
s2 <- rnorm(80, mean = 0.6)

Fn <- ecdf(s1)                                          # empirical CDF as a function
round(Fn(c(-1, 0, 1)), 3)
ks.test(s1, s2)                                         # same distribution?
wilcox.test(s1, s2)                                     # shift in location?

# Quantile comparison, the numbers behind a Q-Q plot
probs <- c(0.1, 0.25, 0.5, 0.75, 0.9)
round(rbind(sample1 = quantile(s1, probs), sample2 = quantile(s2, probs)), 2)

# Sample size for estimating a proportion within +/- 3 points at 95 percent
ceiling(qnorm(0.975)^2 * 0.5 * 0.5 / 0.03^2)

cat("\nDone: all sections ran without errors.\n")
