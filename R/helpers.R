# helpers.R
# Shared helper functions for the regression toolkit (base R only).
# This file only defines functions; it does not run anything by itself.

# -----------------------------------------------------------------------------
# Console input
# -----------------------------------------------------------------------------

# Reads one line; returns `default` when the line is empty.
ask <- function(prompt, default = "") {
  answer <- trimws(readline(prompt))
  if (nchar(answer) == 0) default else answer
}

# Shows a numbered menu and returns the index of the chosen item.
ask_choice <- function(title, choices, default = 1) {
  cat("\n", title, "\n", sep = "")
  for (i in seq_along(choices)) {
    cat(sprintf("  %d) %s\n", i, choices[i]))
  }
  repeat {
    answer <- ask(sprintf("Choice [default %d]: ", default), as.character(default))
    index <- suppressWarnings(as.integer(answer))
    if (!is.na(index) && index >= 1 && index <= length(choices)) {
      return(index)
    }
    cat("Please enter a number from the list.\n")
  }
}

# Asks for a number (a decimal comma is accepted).
ask_number <- function(prompt, default, min = -Inf, max = Inf, integer = FALSE) {
  repeat {
    text <- ask(sprintf("%s [default %s]: ", prompt, default), as.character(default))
    value <- suppressWarnings(as.numeric(sub(",", ".", text, fixed = TRUE)))
    if (!is.na(value) && value >= min && value <= max && (!integer || value == round(value))) {
      return(value)
    }
    cat("Please enter a valid number.\n")
  }
}

# Asks for column names or numbers (from the list shown) and returns the names.
ask_columns <- function(prompt, columns, multiple = TRUE, default = NULL) {
  shown_default <- if (is.null(default)) "" else paste(default, collapse = ", ")
  repeat {
    answer <- ask(prompt, shown_default)
    tokens <- trimws(unlist(strsplit(answer, "[,;[:space:]]+")))
    tokens <- tokens[nchar(tokens) > 0]

    chosen <- vapply(tokens, function(token) {
      index <- suppressWarnings(as.integer(token))
      if (!is.na(index) && index >= 1 && index <= length(columns)) {
        return(columns[index])
      }
      match_index <- match(tolower(token), tolower(columns))
      if (is.na(match_index)) NA_character_ else columns[match_index]
    }, character(1), USE.NAMES = FALSE)

    if (length(chosen) == 0 || anyNA(chosen)) {
      cat("Use column numbers or names from the list.\n")
      next
    }
    chosen <- unique(chosen)
    if (!multiple && length(chosen) != 1) {
      cat("Choose exactly one column.\n")
      next
    }
    return(chosen)
  }
}

# Reads numbers typed by the user, separated by spaces or commas.
read_numbers <- function(prompt) {
  repeat {
    text <- gsub(",", " ", readline(prompt))
    values <- tryCatch(scan(text = text, quiet = TRUE), error = function(e) NULL)
    if (!is.null(values) && length(values) > 0) {
      return(values)
    }
    cat("Please enter numbers only (use a dot for decimals).\n")
  }
}

# -----------------------------------------------------------------------------
# Reading data files
# -----------------------------------------------------------------------------

# Converts text to a number (a decimal comma is accepted); NA when not a number.
to_number <- function(text) {
  suppressWarnings(as.numeric(sub(",", ".", trimws(text), fixed = TRUE)))
}

# TRUE when a row has at least one non-empty cell that is not a number.
looks_like_header <- function(cells) {
  cells <- trimws(cells)
  cells <- cells[nchar(cells) > 0]
  length(cells) > 0 && any(is.na(to_number(cells)))
}

# Tab, semicolon, pipe or comma; NULL means whitespace-separated.
detect_delimiter <- function(lines) {
  sample_lines <- head(lines, 10)
  count <- function(delimiter) {
    vapply(sample_lines, function(line) {
      lengths(regmatches(line, gregexpr(delimiter, line, fixed = TRUE)))
    }, integer(1))
  }
  candidates <- c("\t", ";", "|", ",")
  for (delimiter in candidates) {  # same non-zero count on every line
    counts <- count(delimiter)
    if (length(unique(counts)) == 1 && counts[1] > 0) {
      return(delimiter)
    }
  }
  totals <- vapply(candidates, function(d) as.numeric(sum(count(d))), numeric(1))
  if (max(totals) == 0) NULL else candidates[which.max(totals)]
}

# Converts columns that contain only numbers to numeric; empty cells become NA.
convert_columns <- function(df) {
  for (column in names(df)) {
    text <- trimws(as.character(df[[column]]))
    text[text %in% c("NA", "N/A", "na", "NaN", "null", "NULL")] <- ""
    filled <- nchar(text) > 0
    numbers <- to_number(text)
    if (any(filled) && !anyNA(numbers[filled])) {
      numbers[!filled] <- NA_real_
      df[[column]] <- numbers
    } else {
      text[!filled] <- NA
      df[[column]] <- text
    }
  }
  df
}

# Reads a CSV / TSV / TXT file with automatic delimiter and header detection.
load_data_file <- function(path) {
  path <- gsub("^[\"']|[\"']$", "", trimws(path))
  if (!file.exists(path)) {
    stop(sprintf("File not found: %s", path), call. = FALSE)
  }

  lines <- readLines(path, warn = FALSE)
  lines <- sub("^\xEF\xBB\xBF", "", lines, useBytes = TRUE)
  lines <- iconv(lines, from = "UTF-8", to = "UTF-8", sub = "?")
  lines <- lines[nchar(trimws(lines)) > 0]
  if (length(lines) < 2) {
    stop("The file needs a header row and at least one data row.", call. = FALSE)
  }

  delimiter <- detect_delimiter(lines)
  sep <- if (is.null(delimiter)) "" else delimiter

  connection <- textConnection(lines)
  fields <- count.fields(connection, sep = sep, quote = "\"")
  close(connection)
  width <- max(fields, na.rm = TRUE)

  raw <- read.table(text = lines, sep = sep, quote = "\"", header = FALSE,
                    colClasses = "character", col.names = paste0("V", seq_len(width)),
                    fill = TRUE, strip.white = TRUE, comment.char = "",
                    na.strings = character(0), check.names = FALSE)

  first_row <- unlist(raw[1, ], use.names = FALSE)
  has_header <- looks_like_header(first_row)
  column_names <- if (has_header) trimws(first_row) else paste0("V", seq_len(width))
  if (has_header) raw <- raw[-1, , drop = FALSE]
  column_names[nchar(column_names) == 0] <- paste0("V", which(nchar(column_names) == 0))
  names(raw) <- make.unique(make.names(column_names))

  df <- convert_columns(raw)
  df <- df[vapply(df, function(column) any(!is.na(column)), logical(1))]
  rownames(df) <- NULL
  if (ncol(df) < 2 || nrow(df) < 3) {
    stop("The data needs at least 2 columns and 3 rows.", call. = FALSE)
  }
  df
}

# The built-in example dataset (mtcars without row names).
demo_data <- function() {
  df <- mtcars
  rownames(df) <- NULL
  df
}

numeric_columns <- function(df) {
  names(df)[vapply(df, is.numeric, logical(1))]
}

binary_columns <- function(df) {
  names(df)[vapply(df, function(column) length(unique(na.omit(column))) == 2, logical(1))]
}

# Builds a formula from column names (backticks protect unusual names).
build_formula <- function(response, predictors) {
  as.formula(sprintf("`%s` ~ %s", response, paste0("`", predictors, "`", collapse = " + ")))
}

# -----------------------------------------------------------------------------
# Cross-validation helper
# -----------------------------------------------------------------------------

# Random fold numbers 1..k for n observations (the user's random seed is restored).
make_folds <- function(n, k, seed = 1) {
  k <- max(2, min(k, n))
  old_seed <- if (exists(".Random.seed", envir = globalenv())) {
    get(".Random.seed", envir = globalenv())
  } else {
    NULL
  }
  on.exit(if (!is.null(old_seed)) assign(".Random.seed", old_seed, envir = globalenv()),
          add = TRUE)
  set.seed(seed)
  sample(rep_len(seq_len(k), n))
}

# -----------------------------------------------------------------------------
# Output helpers
# -----------------------------------------------------------------------------

section <- function(title) {
  cat("\n", strrep("=", 70), "\n", title, "\n", strrep("=", 70), "\n", sep = "")
}

format_p <- function(p) {
  ifelse(is.na(p), "NA", ifelse(p < 1e-4, "<0.0001", sprintf("%.4f", p)))
}

# Full path for an output file; creates the folder. NULL when nothing is saved.
out_file <- function(out_dir, name) {
  if (is.null(out_dir)) {
    return(NULL)
  }
  if (!dir.exists(out_dir)) {
    dir.create(out_dir, recursive = TRUE)
  }
  file.path(out_dir, name)
}

# Draws a plot on screen and, if `file` is given, also saves it as a PNG.
render_plot <- function(draw, file = NULL, width = 1100, height = 800, res = 130) {
  draw()
  if (!is.null(file)) {
    png(file, width = width, height = height, res = res)
    tryCatch(draw(), finally = dev.off())
    cat(sprintf("Saved plot: %s\n", file))
  }
  invisible(file)
}

save_table <- function(table, out_dir, name) {
  path <- out_file(out_dir, name)
  if (!is.null(path)) {
    write.csv(table, path, row.names = FALSE)
    cat(sprintf("Saved table: %s\n", path))
  }
  invisible(path)
}
