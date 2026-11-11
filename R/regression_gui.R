# =============================================================================
# regression_gui.R
# A graphical regression tool for R, built with Shiny.
#
# Requirements
#   install.packages("shiny")      # the only package needed
#
# How to run
#   From a terminal:   Rscript regression_gui.R
#   From R / RStudio:  shiny::runApp("regression_gui.R")
#   (the app opens in your web browser)
#
# What it does
#   - Loads a CSV file (or uses the built-in mtcars example)
#   - Lets you pick the response variable, the predictors and the model type
#     (linear, logistic or Poisson)
#   - Shows coefficients, fit statistics, a fit plot, diagnostics and
#     predictions for new values
# =============================================================================

if (!requireNamespace("shiny", quietly = TRUE)) {
  stop("The 'shiny' package is required. Install it with: install.packages(\"shiny\")",
       call. = FALSE)
}
library(shiny)


# -----------------------------------------------------------------------------
# Helper functions
# -----------------------------------------------------------------------------

# Coefficient table with confidence intervals (and ratios for GLMs).
coef_table <- function(model) {
  s <- summary(model)$coefficients
  is_glm <- inherits(model, "glm")
  ci <- if (is_glm) confint.default(model) else confint(model)
  ci <- ci[rownames(s), , drop = FALSE]

  out <- data.frame(
    Term         = rownames(s),
    Estimate     = s[, 1],
    `Std. Error` = s[, 2],
    Statistic    = s[, 3],
    `p-value`    = s[, 4],
    `CI 2.5%`    = ci[, 1],
    `CI 97.5%`   = ci[, 2],
    row.names = NULL,
    check.names = FALSE
  )

  if (is_glm) {
    out$Ratio          <- exp(out$Estimate)
    out$`Ratio CI 2.5%`  <- exp(out$`CI 2.5%`)
    out$`Ratio CI 97.5%` <- exp(out$`CI 97.5%`)
  }
  out
}

# Formats the p-value column as text for display.
format_for_display <- function(tab) {
  tab$`p-value` <- format.pval(tab$`p-value`, digits = 3, eps = 1e-4)
  tab
}

# Fit statistics as lines of text.
metrics_lines <- function(model) {
  n_total <- attr(model, "n_total")
  lines <- sprintf("Observations used: %d", nobs(model))
  if (!is.null(n_total) && n_total > nobs(model)) {
    lines <- c(lines, sprintf("Rows dropped because of missing values: %d",
                              n_total - nobs(model)))
  }

  if (inherits(model, "glm")) {
    pseudo_r2 <- 1 - model$deviance / model$null.deviance
    lines <- c(lines,
      sprintf("Family: %s", model$family$family),
      sprintf("Null deviance: %.3f on %d degrees of freedom",
              model$null.deviance, model$df.null),
      sprintf("Residual deviance: %.3f on %d degrees of freedom",
              model$deviance, model$df.residual),
      sprintf("McFadden pseudo R-squared: %.4f", pseudo_r2),
      sprintf("AIC: %.3f", AIC(model)),
      "Ratio = exp(Estimate): odds ratio (logistic) or rate ratio (Poisson).")

    if (model$family$family == "binomial") {
      predicted <- as.integer(fitted(model) >= 0.5)
      lines <- c(lines,
        sprintf("Classification accuracy (cutoff 0.5): %.4f",
                mean(predicted == model$y)),
        "",
        "Confusion matrix (rows = actual, columns = predicted):",
        capture.output(print(table(actual = model$y, predicted = predicted))))
    }
  } else {
    s  <- summary(model)
    fs <- s$fstatistic
    lines <- c(lines,
      sprintf("R-squared: %.4f", s$r.squared),
      sprintf("Adjusted R-squared: %.4f", s$adj.r.squared),
      sprintf("Residual standard error: %.4f on %d degrees of freedom",
              s$sigma, s$df[2]))
    if (!is.null(fs)) {
      p <- pf(fs[1], fs[2], fs[3], lower.tail = FALSE)
      lines <- c(lines,
        sprintf("F-statistic: %.3f on %d and %d DF, p-value: %s",
                fs[1], fs[2], fs[3], format.pval(p, digits = 3, eps = 1e-4)))
    }
  }
  lines
}

# Variance inflation factors for a linear model.
vif_table <- function(model) {
  X <- model.matrix(model)
  X <- X[, colnames(X) != "(Intercept)", drop = FALSE]
  if (ncol(X) < 2) {
    return(NULL)
  }
  vifs <- sapply(seq_len(ncol(X)), function(j) {
    1 / (1 - summary(lm(X[, j] ~ X[, -j, drop = FALSE]))$r.squared)
  })
  data.frame(variable = colnames(X), VIF = round(vifs, 3))
}

# Diagnostic test results as lines of text (linear models only).
diagnostics_lines <- function(model) {
  if (inherits(model, "glm")) {
    return("Numeric diagnostic tests are available for linear models only.\nThe plots above are shown for the fitted GLM.")
  }

  n <- nobs(model)
  e <- residuals(model)
  lines <- character(0)

  if (n >= 3 && n <= 5000) {
    sw <- shapiro.test(e)
    lines <- c(lines, sprintf(
      "Shapiro-Wilk (residual normality):   W = %.4f, p = %.4f", sw$statistic, sw$p.value))
  }

  X <- model.matrix(model)
  X <- X[, colnames(X) != "(Intercept)", drop = FALSE]
  if (ncol(X) >= 1 && n > ncol(X) + 1) {
    aux <- summary(lm(e^2 ~ X))
    lm_stat <- n * aux$r.squared
    lines <- c(lines, sprintf(
      "Breusch-Pagan (equal variance):      LM = %.4f, df = %d, p = %.4f",
      lm_stat, ncol(X), pchisq(lm_stat, ncol(X), lower.tail = FALSE)))
  }

  lines <- c(lines, sprintf(
    "Durbin-Watson (autocorrelation):     DW = %.4f (about 2 means none)",
    sum(diff(e)^2) / sum(e^2)))

  cd <- cooks.distance(model)
  lines <- c(lines, sprintf(
    "Cook's distance above 4/n:           %d observation(s)", sum(cd > 4 / n)))

  v <- vif_table(model)
  if (!is.null(v)) {
    lines <- c(lines, "", "Variance inflation factors (above 5-10 suggests collinearity):",
               capture.output(print(v, row.names = FALSE)))
  }

  c(lines, "", "A p-value below 0.05 in the first two tests suggests the assumption is violated.")
}

# Fit plot: data with the fitted curve (one numeric predictor),
# otherwise observed versus fitted values.
draw_fit_plot <- function(model) {
  mf <- model.frame(model)
  y <- if (inherits(model, "glm")) model$y else mf[[1]]
  y_name <- names(mf)[1]
  pred_names <- names(mf)[-1]
  point_col <- adjustcolor("steelblue", 0.75)

  if (length(pred_names) == 1 && is.numeric(mf[[2]])) {
    x <- mf[[2]]
    grid <- data.frame(seq(min(x), max(x), length.out = 200))
    names(grid) <- pred_names

    plot(x, y, pch = 19, col = point_col, xlab = pred_names, ylab = y_name,
         main = paste("Fitted model:", y_name, "~", pred_names))

    if (inherits(model, "glm")) {
      lines(grid[[1]], predict(model, grid, type = "response"),
            col = "firebrick", lwd = 2)
    } else {
      p <- predict(model, grid, interval = "confidence")
      polygon(c(grid[[1]], rev(grid[[1]])), c(p[, "lwr"], rev(p[, "upr"])),
              col = adjustcolor("firebrick", 0.15), border = NA)
      lines(grid[[1]], p[, "fit"], col = "firebrick", lwd = 2)
    }
  } else {
    plot(fitted(model), y, pch = 19, col = point_col,
         xlab = "Fitted values", ylab = paste("Observed", y_name),
         main = "Observed versus fitted values")
    abline(0, 1, col = "firebrick", lwd = 2)
  }
  grid()
}


# -----------------------------------------------------------------------------
# User interface
# -----------------------------------------------------------------------------
ui <- fluidPage(
  titlePanel("Regression Explorer"),

  sidebarLayout(
    sidebarPanel(
      width = 3,
      radioButtons("source", "Data source",
                   choices = c("Upload a CSV file" = "upload",
                               "Use the example dataset (mtcars)" = "mtcars"),
                   selected = "mtcars"),
      conditionalPanel(
        "input.source == 'upload'",
        fileInput("file", "CSV file", accept = c(".csv", "text/csv")),
        checkboxInput("header", "First row contains column names", TRUE)
      ),
      hr(),
      uiOutput("response_ui"),
      uiOutput("predictors_ui"),
      selectInput("family", "Model type",
                  choices = c("Linear regression (OLS)" = "gaussian",
                              "Logistic regression" = "binomial",
                              "Poisson regression" = "poisson")),
      checkboxInput("intercept", "Include intercept", TRUE),
      actionButton("run", "Run regression", class = "btn-primary")
    ),

    mainPanel(
      width = 9,
      tabsetPanel(
        tabPanel("Data",
                 br(), textOutput("data_info"), br(),
                 tableOutput("data_table")),

        tabPanel("Results",
                 br(), h4("Model fit"), verbatimTextOutput("metrics"),
                 h4("Coefficients"), tableOutput("coef_table"),
                 downloadButton("download_coef", "Download coefficients (CSV)"),
                 br(), br(), h4("Full R summary"), verbatimTextOutput("full_summary")),

        tabPanel("Fit plot",
                 br(), plotOutput("fit_plot", height = "520px"),
                 downloadButton("download_plot", "Download plot (PNG)")),

        tabPanel("Diagnostics",
                 br(), plotOutput("diag_plot", height = "650px"),
                 verbatimTextOutput("diag_text")),

        tabPanel("Predict",
                 br(), uiOutput("predict_inputs"), br(),
                 tableOutput("predict_out"))
      )
    )
  )
)


# -----------------------------------------------------------------------------
# Server logic
# -----------------------------------------------------------------------------
server <- function(input, output, session) {

  # ---- Data -----------------------------------------------------------------
  raw_data <- reactive({
    if (input$source == "mtcars") {
      return(mtcars)
    }
    req(input$file)
    tryCatch(
      read.csv(input$file$datapath, header = isTRUE(input$header),
               stringsAsFactors = TRUE),
      error = function(e) {
        validate(need(FALSE, paste("Could not read the file:", conditionMessage(e))))
      }
    )
  })

  output$data_info <- renderText({
    d <- raw_data()
    sprintf("%d rows, %d columns. %s", nrow(d), ncol(d),
            if (nrow(d) > 100) "Showing the first 100 rows." else "")
  })

  output$data_table <- renderTable(head(raw_data(), 100), rownames = TRUE)

  # ---- Variable selection ---------------------------------------------------
  output$response_ui <- renderUI({
    d <- raw_data()
    selected <- if (input$source == "mtcars") "mpg" else tail(names(d), 1)
    selectInput("response", "Response variable (y)",
                choices = names(d), selected = selected)
  })

  output$predictors_ui <- renderUI({
    d <- raw_data()
    req(input$response)
    others <- setdiff(names(d), input$response)
    kept <- intersect(isolate(input$predictors), others)
    selected <- if (length(kept) > 0) {
      kept
    } else if (input$source == "mtcars" && all(c("wt", "hp") %in% others)) {
      c("wt", "hp")
    } else {
      head(others, 3)
    }
    selectInput("predictors", "Predictor variables (x)",
                choices = others, selected = selected, multiple = TRUE)
  })

  # Suggest logistic regression when the response has exactly two values.
  observeEvent(input$response, {
    d <- raw_data()
    req(input$response %in% names(d))
    n_values <- length(unique(na.omit(d[[input$response]])))
    updateSelectInput(session, "family",
                      selected = if (n_values == 2) "binomial" else "gaussian")
  })

  # ---- Model ----------------------------------------------------------------
  model <- eventReactive(input$run, {
    d <- raw_data()
    validate(
      need(!is.null(input$response) && nzchar(input$response),
           "Select a response variable."),
      need(length(input$predictors) > 0, "Select at least one predictor.")
    )

    rhs <- paste0("`", input$predictors, "`", collapse = " + ")
    if (!isTRUE(input$intercept)) rhs <- paste(rhs, "- 1")
    f <- as.formula(paste0("`", input$response, "` ~ ", rhs))

    if (input$family == "gaussian" && !is.numeric(d[[input$response]])) {
      validate(need(FALSE,
        "The response is not numeric. Choose logistic regression for a two-class response."))
    }

    fit <- tryCatch(
      if (input$family == "gaussian") lm(f, data = d)
      else glm(f, data = d, family = input$family),
      error = function(e) {
        validate(need(FALSE, paste("The model could not be fitted:", conditionMessage(e))))
      }
    )
    fit$call$formula <- f
    fit$call$data <- quote(data)
    attr(fit, "n_total") <- nrow(d)
    fit
  })

  # Shows a hint until the first run.
  current_model <- reactive({
    validate(need(!is.null(input$run) && input$run > 0,
                  "Choose the variables and press 'Run regression'."))
    model()
  })

  # ---- Results --------------------------------------------------------------
  output$metrics <- renderText(paste(metrics_lines(current_model()), collapse = "\n"))

  output$coef_table <- renderTable(
    format_for_display(coef_table(current_model())),
    digits = 4
  )

  output$full_summary <- renderPrint(print(summary(current_model())))

  output$download_coef <- downloadHandler(
    filename = function() "coefficients.csv",
    content = function(file) {
      write.csv(coef_table(current_model()), file, row.names = FALSE)
    }
  )

  # ---- Plots ----------------------------------------------------------------
  output$fit_plot <- renderPlot(draw_fit_plot(current_model()))

  output$download_plot <- downloadHandler(
    filename = function() "fit_plot.png",
    content = function(file) {
      png(file, width = 1100, height = 750, res = 130)
      draw_fit_plot(current_model())
      dev.off()
    }
  )

  output$diag_plot <- renderPlot({
    op <- par(mfrow = c(2, 2))
    on.exit(par(op))
    plot(current_model(), which = 1:4)
  })

  output$diag_text <- renderText(paste(diagnostics_lines(current_model()), collapse = "\n"))

  # ---- Prediction -----------------------------------------------------------
  output$predict_inputs <- renderUI({
    m <- current_model()
    mf <- model.frame(m)
    preds <- names(mf)[-1]

    inputs <- lapply(seq_along(preds), function(i) {
      col <- mf[[preds[i]]]
      id <- paste0("pred_", i)
      if (is.numeric(col)) {
        column(3, numericInput(id, preds[i], value = signif(median(col), 4)))
      } else {
        column(3, selectInput(id, preds[i], choices = levels(factor(col))))
      }
    })
    tagList(h4("Enter predictor values"), fluidRow(inputs))
  })

  output$predict_out <- renderTable({
    m <- current_model()
    mf <- model.frame(m)
    preds <- names(mf)[-1]

    values <- lapply(seq_along(preds), function(i) {
      v <- input[[paste0("pred_", i)]]
      req(!is.null(v))
      col <- mf[[preds[i]]]
      if (is.numeric(col)) {
        req(!is.na(v))
        v
      } else {
        factor(v, levels = levels(factor(col)))
      }
    })
    names(values) <- preds
    newdata <- as.data.frame(values, check.names = FALSE)

    if (inherits(m, "glm")) {
      label <- if (m$family$family == "binomial") "Predicted probability" else "Predicted rate"
      result <- data.frame(predicted = predict(m, newdata, type = "response"))
      names(result) <- label
    } else {
      p <- predict(m, newdata, interval = "prediction", level = 0.95)
      result <- data.frame(Prediction = p[, "fit"],
                           `Lower 95%` = p[, "lwr"],
                           `Upper 95%` = p[, "upr"],
                           check.names = FALSE)
    }
    result
  }, digits = 4)
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
