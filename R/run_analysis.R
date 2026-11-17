# run_analysis.R
# Interactive menu for the regression toolkit. Run it in R or RStudio:
#
#   source("run_analysis.R")
#
# The menu loads your data (CSV / TSV / TXT file, values typed by hand, or the
# built-in mtcars example) and lets you choose an analysis. All modules live in the
# same folder and can also be used directly, for example:
#
#   source("helpers.R"); source("linear.R")
#   df <- load_data_file("mydata.csv")
#   linear_regression(df, "price", c("area", "rooms"))
#
# Modules (base R only, no packages to install):
#   helpers.R          shared helpers (data loading, prompts, plots)
#   descriptive.R      descriptive statistics, correlations
#   linear.R           multiple linear regression with diagnostics
#   polynomial.R       polynomial regression with degree selection
#   selection.R        variable selection (best subsets, stepwise)
#   regularized.R      ridge and lasso regression
#   logistic.R         logistic regression, ROC, AUC
#   hypothesis_tests.R group comparisons and chi-square tests
#   timeseries.R       time series forecasting

# Folder of this file (works with source() and RStudio's Source button).
toolkit_dir <- local({
  source_files <- Filter(Negate(is.null), lapply(sys.frames(), function(frame) frame$ofile))
  if (length(source_files) > 0) {
    dirname(normalizePath(source_files[[length(source_files)]]))
  } else {
    getwd()
  }
})

for (module in c("helpers.R", "descriptive.R", "linear.R", "polynomial.R", "selection.R",
                 "regularized.R", "logistic.R", "hypothesis_tests.R", "timeseries.R")) {
  module_path <- file.path(toolkit_dir, module)
  if (!file.exists(module_path)) {
    stop(sprintf("Missing file: %s\nKeep all toolkit files in the same folder.", module_path),
         call. = FALSE)
  }
  source(module_path)
}

# -----------------------------------------------------------------------------
# Getting the data
# -----------------------------------------------------------------------------

# Builds a data frame from values typed by the user.
type_data <- function() {
  k <- ask_number("How many variables (columns)", 3, min = 2, max = 30, integer = TRUE)
  column_names <- character(k)
  columns <- vector("list", k)
  for (i in seq_len(k)) {
    column_names[i] <- ask(sprintf("Name of variable %d [default v%d]: ", i, i), paste0("v", i))
    columns[[i]] <- read_numbers(sprintf("Values of '%s' (numbers separated by spaces or commas): ",
                                         column_names[i]))
  }
  if (length(unique(lengths(columns))) != 1) {
    cat("All variables must have the same number of values:\n")
    for (i in seq_len(k)) cat(sprintf("  %s: %d values\n", column_names[i], length(columns[[i]])))
    return(NULL)
  }
  df <- as.data.frame(columns)
  names(df) <- make.unique(make.names(column_names))
  df
}

choose_data <- function() {
  repeat {
    choice <- ask_choice("Where is your data?", c(
      "Open a CSV / TSV / TXT file (file chooser window)",
      "Enter a file path",
      "Type the values by hand",
      "Use the built-in example dataset (mtcars)"), default = 1)

    df <- tryCatch({
      if (choice == 1) {
        path <- tryCatch(file.choose(), error = function(e) NULL)
        if (is.null(path)) NULL else load_data_file(path)
      } else if (choice == 2) {
        path <- ask("Path to the file: ")
        if (nchar(path) == 0) NULL else load_data_file(path)
      } else if (choice == 3) {
        type_data()
      } else {
        demo_data()
      }
    }, error = function(e) {
      cat("Could not load the data: ", conditionMessage(e), "\n", sep = "")
      NULL
    })

    if (!is.null(df)) {
      return(df)
    }
    again <- tolower(ask("Try again? [Y/n]: ", "y"))
    if (!(again %in% c("y", "yes"))) {
      return(NULL)
    }
  }
}

show_columns <- function(df) {
  cat(sprintf("\nData: %d rows, %d columns\n", nrow(df), ncol(df)))
  info <- data.frame(
    number = seq_along(df), column = names(df),
    type = vapply(df, function(col) if (is.numeric(col)) "numeric" else "text", character(1)),
    distinct = vapply(df, function(col) length(unique(na.omit(col))), integer(1)),
    missing = vapply(df, function(col) sum(is.na(col)), integer(1)),
    row.names = NULL
  )
  print(info, row.names = FALSE)
}

# -----------------------------------------------------------------------------
# Column prompts
# -----------------------------------------------------------------------------

# Asks for numeric columns (by number or name, using the numbering shown above).
ask_numeric <- function(prompt, df, multiple = FALSE, default = NULL) {
  repeat {
    chosen <- ask_columns(prompt, names(df), multiple = multiple, default = default)
    not_numeric <- chosen[!vapply(df[chosen], is.numeric, logical(1))]
    if (length(not_numeric) == 0) {
      return(chosen)
    }
    cat("These columns are not numeric: ", paste(not_numeric, collapse = ", "), "\n", sep = "")
    default <- NULL
  }
}

other_numeric <- function(df, exclude) {
  setdiff(numeric_columns(df), exclude)
}

# -----------------------------------------------------------------------------
# One handler per analysis
# -----------------------------------------------------------------------------
run_descriptive <- function(df, out_dir) {
  columns <- ask_numeric("Numeric columns (numbers or names) [Enter = all numeric]: ", df,
                         multiple = TRUE, default = numeric_columns(df))
  describe_data(df, columns)
  if (length(columns) >= 2) {
    method <- c("pearson", "spearman")[ask_choice("Correlation method:",
                c("Pearson (linear relationships)", "Spearman (ranks; robust to outliers)"))]
    correlation_analysis(df, columns, method, out_dir)
  }
}

run_linear <- function(df, out_dir) {
  response <- ask_numeric("Response variable (y): ", df)
  default <- other_numeric(df, response)
  predictors <- ask_columns("Predictors (numbers or names, separated by spaces) [Enter = all other numeric]: ",
                            names(df), default = default)
  predictors <- setdiff(predictors, response)
  linear_regression(df, response, predictors, out_dir)
}

run_polynomial <- function(df, out_dir) {
  x <- ask_numeric("Predictor (x): ", df)
  y <- ask_numeric("Response (y): ", df)
  max_degree <- ask_number("Maximum polynomial degree to test", 5, min = 2, max = 10, integer = TRUE)
  polynomial_regression(df, x, y, max_degree, out_dir = out_dir)
}

run_selection <- function(df, out_dir) {
  response <- ask_numeric("Response variable (y): ", df)
  candidates <- other_numeric(df, response)
  predictors <- ask_numeric("Candidate predictors [Enter = all other numeric]: ", df,
                            multiple = TRUE, default = candidates)
  best_subsets(df, response, setdiff(predictors, response), out_dir = out_dir)
}

run_regularized <- function(df, out_dir) {
  response <- ask_numeric("Response variable (y): ", df)
  candidates <- other_numeric(df, response)
  predictors <- ask_numeric("Predictors [Enter = all other numeric]: ", df,
                            multiple = TRUE, default = candidates)
  method <- c("lasso", "ridge")[ask_choice("Method:", c(
    "Lasso (can remove variables by setting coefficients to exactly zero)",
    "Ridge (shrinks coefficients; good for correlated predictors)"))]
  regularized_regression(df, response, setdiff(predictors, response), method, out_dir = out_dir)
}

run_logistic <- function(df, out_dir) {
  binary <- binary_columns(df)
  if (length(binary) == 0) {
    stop("No column has exactly two distinct values, so there is no binary response.", call. = FALSE)
  }
  cat("Columns with exactly two values (possible responses): ", paste(binary, collapse = ", "), "\n", sep = "")
  response <- ask_columns("Binary response variable: ", names(df), multiple = FALSE)
  default <- other_numeric(df, response)
  predictors <- ask_columns("Predictors [Enter = all other numeric]: ", names(df), default = default)
  threshold <- ask_number("Classification threshold", 0.5, min = 0.01, max = 0.99)
  logistic_regression(df, response, setdiff(predictors, response), threshold, out_dir = out_dir)
}

run_two_groups <- function(df, out_dir) {
  value <- ask_numeric("Numeric variable to compare: ", df)
  group <- ask_columns("Grouping variable (exactly 2 groups): ", names(df), multiple = FALSE)
  compare_two_groups(df, value, group, out_dir)
}

run_paired <- function(df, out_dir) {
  before <- ask_numeric("'Before' measurement: ", df)
  after <- ask_numeric("'After' measurement: ", df)
  compare_paired(df, before, after, out_dir)
}

run_many_groups <- function(df, out_dir) {
  value <- ask_numeric("Numeric variable to compare: ", df)
  group <- ask_columns("Grouping variable (3 or more groups): ", names(df), multiple = FALSE)
  compare_many_groups(df, value, group, out_dir)
}

run_chi_square <- function(df, out_dir) {
  vars <- ask_columns("Two categorical variables (numbers or names): ", names(df), multiple = TRUE)
  if (length(vars) != 2) {
    stop("Choose exactly two variables.", call. = FALSE)
  }
  chi_square_independence(df, vars[1], vars[2], out_dir)
}

run_time_series <- function(df, out_dir) {
  value <- ask_numeric("Series to forecast: ", df)
  time_answer <- ask("Time / date column (Enter = the rows are already in time order): ", "")
  time <- NULL
  if (nchar(time_answer) > 0) {
    time <- ask_columns("Time column: ", names(df), multiple = FALSE, default = time_answer)
  }
  horizon <- ask_number("Number of future periods to forecast", 6, min = 1, max = 100, integer = TRUE)
  season <- ask_number("Seasonal period (12 = monthly data with yearly pattern, 4 = quarterly, 0 = none)",
                       0, min = 0, max = 100, integer = TRUE)
  window <- ask_number("Moving average window", 3, min = 2, max = 24, integer = TRUE)
  time_series_analysis(df, value, time, horizon, season_length = if (season >= 2) season else NULL,
                       ma_window = window, out_dir = out_dir)
}

# -----------------------------------------------------------------------------
# Main menu
# -----------------------------------------------------------------------------
run_toolkit <- function() {
  cat("\n", strrep("=", 70), "\n", "Regression and statistics toolkit\n", strrep("=", 70), "\n", sep = "")

  folder <- ask("Folder for saving plots and tables (Enter = do not save): ", "")
  out_dir <- if (nchar(folder) == 0) NULL else folder

  df <- choose_data()
  if (is.null(df)) {
    return(invisible(NULL))
  }
  show_columns(df)

  actions <- list(
    list("Descriptive statistics and correlations", run_descriptive),
    list("Linear regression (several predictors) with diagnostics", run_linear),
    list("Polynomial regression (one predictor, curved relationship)", run_polynomial),
    list("Variable selection (which predictors matter?)", run_selection),
    list("Ridge / lasso regression (many or correlated predictors)", run_regularized),
    list("Logistic regression (yes/no outcome)", run_logistic),
    list("Compare two groups (t-test, Mann-Whitney)", run_two_groups),
    list("Paired comparison (before / after)", run_paired),
    list("Compare three or more groups (ANOVA, Kruskal-Wallis)", run_many_groups),
    list("Association of two categorical variables (chi-square)", run_chi_square),
    list("Time series forecasting", run_time_series)
  )
  labels <- c(vapply(actions, function(a) a[[1]], character(1)),
              "Show the columns of the data again", "Load different data", "Exit")

  repeat {
    choice <- ask_choice("What would you like to do?", labels, default = 1)
    if (choice == length(labels)) {
      break
    }
    if (choice == length(labels) - 1) {
      new_data <- choose_data()
      if (!is.null(new_data)) {
        df <- new_data
        show_columns(df)
      }
      next
    }
    if (choice == length(labels) - 2) {
      show_columns(df)
      next
    }

    tryCatch(
      actions[[choice]][[2]](df, out_dir),
      error = function(e) cat("\nCould not run the analysis: ", conditionMessage(e), "\n", sep = "")
    )
  }

  if (!is.null(out_dir)) {
    cat(sprintf("\nSaved files are in: %s\n", normalizePath(out_dir)))
  }
  cat("Finished.\n")
  invisible(NULL)
}

if (interactive()) {
  run_toolkit()
} else {
  cat("Toolkit loaded. Open R or RStudio and run source(\"run_analysis.R\") to start the menu.\n")
}
