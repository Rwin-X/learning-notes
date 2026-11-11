# simple_regression.R
# Asks for the data, then computes a linear regression.
# Run with: Rscript simple_regression.R

con <- file("stdin", "r")

ask <- function(message) {
  cat(message)
  trimws(readLines(con, n = 1))
}

# 1. Get the data
path <- ask("Path to CSV file: ")
data <- read.csv(path)
cat("Columns:", paste(names(data), collapse = ", "), "\n")

# 2. Choose the variables
response   <- ask("Response variable: ")
predictors <- trimws(strsplit(ask("Predictors (comma separated): "), ",")[[1]])

# 3. Compute
model <- lm(reformulate(predictors, response), data = data)

print(summary(model))
print(confint(model))
