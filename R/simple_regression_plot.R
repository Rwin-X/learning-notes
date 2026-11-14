# simple_regression_plot.R
# Enter the data, then the regression is computed and its plot is shown.
#
# How to run (in R or RStudio):
#   source("simple_regression_plot.R")

# 1. Get the data (values separated by spaces or commas)
read_numbers <- function(prompt) {
  text <- gsub(",", " ", readline(prompt))
  scan(text = text, quiet = TRUE)
}

x <- read_numbers("Enter the x values: ")
y <- read_numbers("Enter the y values: ")

if (length(x) != length(y)) stop("x and y must have the same number of values.")
if (length(x) < 3) stop("Enter at least 3 pairs of values.")

# 2. Compute the regression
model <- lm(y ~ x)
print(summary(model))

# 3. Show the regression plot
equation <- sprintf("y = %.3f + %.3f x   (R-squared = %.3f)",
                    coef(model)[1], coef(model)[2], summary(model)$r.squared)

plot(x, y, pch = 19, col = "steelblue", xlab = "x", ylab = "y",
     main = equation)
abline(model, col = "red", lwd = 2)
