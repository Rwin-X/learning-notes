# =============================================================================
# simple_regression_gui.R
# A small graphical tool for simple linear regression, built with Shiny.
#
# Type the data into the table (columns x and y) and press Calculate:
# the regression plot and the results appear next to the table.
#
# Requirements
#   install.packages("shiny")
#
# How to run
#   From a terminal:   Rscript simple_regression_gui.R
#   From R / RStudio:  shiny::runApp("simple_regression_gui.R")
#   (the app opens in your web browser)
# =============================================================================

if (!requireNamespace("shiny", quietly = TRUE)) {
  stop("The 'shiny' package is required. Install it with: install.packages(\"shiny\")",
       call. = FALSE)
}
library(shiny)

START_ROWS <- 12

example_table <- data.frame(
  x = c("1", "2", "3", "4", "5", "6", "7", "8"),
  y = c("2.1", "4.3", "5.9", "8.2", "9.8", "12.1", "14.2", "15.9"),
  stringsAsFactors = FALSE
)


# -----------------------------------------------------------------------------
# Helper functions
# -----------------------------------------------------------------------------

# Text to number (a decimal comma is accepted). Returns NA when not a number.
parse_number <- function(text) {
  value <- suppressWarnings(as.numeric(sub(",", ".", trimws(text), fixed = TRUE)))
  ifelse(is.finite(value), value, NA_real_)
}

blank_table <- function(n = START_ROWS) {
  data.frame(x = rep("", n), y = rep("", n), stringsAsFactors = FALSE)
}

pad_table <- function(tbl, n = START_ROWS) {
  if (nrow(tbl) < n) {
    tbl <- rbind(tbl, blank_table(n - nrow(tbl)))
  }
  tbl
}

# Reads two pasted columns (Excel, CSV or plain text). Returns NULL if none found.
parse_pasted <- function(text) {
  lines <- trimws(strsplit(text, "\r?\n")[[1]])
  lines <- lines[nzchar(lines)]

  pairs <- lapply(lines, function(line) {
    parts <- strsplit(line, "[\t;[:space:]]+")[[1]]
    parts <- gsub("^[,;]+|[,;]+$", "", parts)
    parts <- parts[nzchar(parts)]
    if (length(parts) == 1 && grepl(",", parts)) {
      parts <- strsplit(parts, ",")[[1]]
      parts <- parts[nzchar(parts)]
    }
    if (length(parts) >= 2) parts[1:2] else NULL
  })
  pairs <- Filter(Negate(is.null), pairs)
  if (length(pairs) == 0) {
    return(NULL)
  }

  tbl <- data.frame(x = vapply(pairs, `[`, character(1), 1),
                    y = vapply(pairs, `[`, character(1), 2),
                    stringsAsFactors = FALSE)

  # Skip a header row such as "x y"
  if (is.na(parse_number(tbl$x[1]))) {
    tbl <- tbl[-1, , drop = FALSE]
  }
  rownames(tbl) <- NULL
  if (nrow(tbl) == 0) NULL else tbl
}

# Validates the table and fits the model. Always returns a list with $status.
compute_regression <- function(tbl) {
  fail <- function(message) list(status = "error", message = message)

  x_text <- trimws(tbl$x)
  y_text <- trimws(tbl$y)
  rows <- which(nzchar(x_text) | nzchar(y_text))

  if (length(rows) == 0) {
    return(fail("The table is empty. Enter the x and y values."))
  }

  for (i in rows) {
    if (!nzchar(x_text[i]) || !nzchar(y_text[i])) {
      return(fail(sprintf("Row %d is incomplete: fill both x and y, or leave both empty.", i)))
    }
    if (is.na(parse_number(x_text[i]))) {
      return(fail(sprintf("Row %d: x value '%s' is not a number.", i, x_text[i])))
    }
    if (is.na(parse_number(y_text[i]))) {
      return(fail(sprintf("Row %d: y value '%s' is not a number.", i, y_text[i])))
    }
  }

  x <- parse_number(x_text[rows])
  y <- parse_number(y_text[rows])

  if (length(x) < 3) {
    return(fail("Enter at least 3 pairs of values."))
  }
  if (length(unique(x)) < 2) {
    return(fail("All x values are identical, so a regression line cannot be computed."))
  }

  list(status = "ok", x = x, y = y, model = lm(y ~ x))
}

equation_text <- function(model) {
  b <- coef(model)
  sprintf("y = %.3f %s %.3f x", b[1], if (b[2] < 0) "-" else "+", abs(b[2]))
}


# -----------------------------------------------------------------------------
# User interface
# -----------------------------------------------------------------------------
ui <- fluidPage(
  tags$style(HTML("
    .grid-scroll { max-height: 400px; overflow-y: auto; padding-right: 6px; }
    .grid-scroll .form-group { margin-bottom: 4px; }
    .grid-head { font-weight: 600; text-align: center; }
    .row-number { padding-top: 7px; text-align: center; color: #777; }
  ")),

  titlePanel("Simple Regression Tool"),

  sidebarLayout(
    sidebarPanel(
      width = 4,
      h4("Data"),
      fluidRow(
        column(2, div(class = "grid-head", "#")),
        column(5, div(class = "grid-head", "x")),
        column(5, div(class = "grid-head", "y"))
      ),
      div(class = "grid-scroll", uiOutput("grid")),
      br(),
      fluidRow(
        column(6, actionButton("add_row", "Add row", width = "100%")),
        column(6, actionButton("clear", "Clear", width = "100%"))
      ),
      br(),
      fluidRow(
        column(12, actionButton("example", "Load example", width = "100%"))
      ),
      br(),
      textAreaInput("paste_text", "Or paste two columns (from Excel or CSV)",
                    rows = 3, width = "100%"),
      actionButton("use_paste", "Use pasted data", width = "100%"),
      hr(),
      actionButton("run", "Calculate", class = "btn-primary", width = "100%")
    ),

    mainPanel(
      width = 8,
      plotOutput("plot", height = "430px"),
      br(),
      verbatimTextOutput("results")
    )
  )
)


# -----------------------------------------------------------------------------
# Server logic
# -----------------------------------------------------------------------------
server <- function(input, output, session) {

  table_data <- reactiveVal(blank_table())
  outcome    <- reactiveVal(list(status = "empty"))

  # The values currently typed in the grid
  read_grid <- function() {
    n <- nrow(table_data())
    cell <- function(id) {
      value <- input[[id]]
      if (is.null(value)) "" else as.character(value)
    }
    data.frame(
      x = vapply(seq_len(n), function(i) cell(paste0("x_", i)), character(1)),
      y = vapply(seq_len(n), function(i) cell(paste0("y_", i)), character(1)),
      stringsAsFactors = FALSE
    )
  }

  # ---- Data grid ------------------------------------------------------------
  output$grid <- renderUI({
    d <- table_data()
    rows <- lapply(seq_len(nrow(d)), function(i) {
      fluidRow(
        column(2, div(class = "row-number", i)),
        column(5, textInput(paste0("x_", i), label = NULL, value = d$x[i], width = "100%")),
        column(5, textInput(paste0("y_", i), label = NULL, value = d$y[i], width = "100%"))
      )
    })
    tagList(rows)
  })

  observeEvent(input$add_row, {
    table_data(rbind(read_grid(), data.frame(x = "", y = "", stringsAsFactors = FALSE)))
  })

  observeEvent(input$clear, {
    table_data(blank_table())
    outcome(list(status = "empty"))
  })

  observeEvent(input$example, {
    table_data(pad_table(example_table))
  })

  observeEvent(input$use_paste, {
    pasted <- parse_pasted(input$paste_text)
    if (is.null(pasted)) {
      showNotification("No two-column data was found in the pasted text.", type = "warning")
    } else {
      table_data(pad_table(pasted))
    }
  })

  # ---- Calculation ----------------------------------------------------------
  observeEvent(input$run, {
    outcome(compute_regression(read_grid()))
  })

  current <- function() {
    o <- outcome()
    validate(need(o$status != "empty", "Enter the data in the table and press Calculate."))
    validate(need(o$status != "error", o$message))
    o
  }

  # ---- Output ---------------------------------------------------------------
  output$plot <- renderPlot({
    o <- current()
    model <- o$model

    plot(o$x, o$y, pch = 19, col = "steelblue", cex = 1.4, xlab = "x", ylab = "y",
         main = sprintf("%s   (R-squared = %.3f)", equation_text(model),
                        summary(model)$r.squared))
    abline(model, col = "red", lwd = 2)
    grid()
    legend("topleft", legend = c("Data", "Regression line"),
           pch = c(19, NA), lty = c(NA, 1), lwd = c(NA, 2),
           col = c("steelblue", "red"), bty = "n")
  })

  output$results <- renderPrint({
    o <- current()
    cat("Equation:", equation_text(o$model), "\n")
    cat("n       :", length(o$x), "\n")
    print(summary(o$model))
  })
}


# -----------------------------------------------------------------------------
# Launch
# -----------------------------------------------------------------------------
app <- shinyApp(ui, server)

# When run with Rscript, start the app and open the browser.
if (sys.nframe() == 0) {
  runApp(app, launch.browser = TRUE)
}

app
