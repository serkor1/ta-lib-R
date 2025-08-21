#' @export
chart <- function(
  x, 
  type = "candlestick", 
  ...) {
    UseMethod(
      "chart"
    )
}

#' @export
chart.default <- function(
  x,
  type = "candlestick",
  ...) {

    ## default chart function
    ## 
    ## The chart function works as an initializer
    ## for the downstream indicator function calls
    ##
    ## There are three chart lists:
    ##    1. main: The candlestick/bar chart. This is where all
    ##             all indicators that are charted on the candlestick
    ##             lives alongside the pricechart itself.
    ##    2. sub:  A list of indicators. This is where all indicators
    ##             that are charted below the main chart lives. For example
    ##             RSI, MACD etc.
    ##    3. chart: The user-facing TA chart. 
    ##              This is empty and is constructed on the fly 
    ##              via plotly::subplot.
    .color_values <- chart.theme()
    .plotting_environment$sub <- .plotting_environment$chart <- list()

    ## convert input to data.frame object
    ## and store in the .plotting_environment
    ## to avoid having to pass OHLC on every call
    ##
    ## NOTE: it is also a hard requirement on
    ##       {plotly} side
    .plotting_environment$x <- data_frame <- as.data.frame(x); 
  
    ## generate price chart
    ## based on type. can be either 
    ## candlestick or barchart.
    ##
    ## TODO: Consider adding the option to use price series
    ##       instead of OHLC.
    assert(is.character(type) && length(type) == 1)
    assert(type %in% c("candlestick", "ohlc"))

    price_chart <- plotly::plot_ly(
      data  = data_frame,
      type  = type,
      open  = ~open, close = ~close, high  = ~high, low = ~low,

      ## colors of bullish
      ## and bearish candles/bars
      ##
      ## NOTE: if fillcolor is NULL
      ##       the candles are hollow.
      ##       If there is eventual demand this can be changed
      increasing = list(
        line = list(
          color = .color_values$bull_color,
          width = 3 - 1.75
          ),
        fillcolor = plotly::toRGB(
          x = .color_values$bull_color,
          alpha = 1 ## This should be controlled from .chart_theme()
          )
      ),
      decreasing = list(
        line = list(
          color = .color_values$bear_color, 
          width = 3 - 1.75
          ),

        fillcolor = plotly::toRGB(
          x = .color_values$bear_color,
          alpha = 1 ## This should be controlled from .chart_theme()
          )
      ),
      ...
    )

    ## store in main chart
    ## (see description)
    .plotting_environment$main <- .chart_layout(
      x = price_chart,
      title_text = sprintf(
        "<b>Ticker:</b> %s <br><sub><b>Period:</b> %s</sub>",
        deparse(substitute(x)),
        "Period Value"
      )
    )

    .plotting_environment$main  
}

#' @export
indicator <- function(
  .f, 
  .var, 
  ...) {

    ## Indicator function
    ##
    ## Description
    ##  This function is essentially a wrapper
    ##  of model.matrix, model.frame and various indicator
    ##  functions in TA-lib.
    ##
    ## Argument
    ##  .f: The indicator function. Eg. talib::SMA()
    ##  .var: A formula indicating which variables (and data, optionally)
    ##        to pass into .f
    ##  ...: Additional arguments passed into model.matrix and model.frame
    ##
    ## NOTE: The function "works" and does what it is supposed to do.
    ##       but it needs some serious refactoring and modularization.
    parent_frame <- parent.frame()

    ## parse and check formula
    passed_formula <- eval.parent(
      substitute(.var)
    )

    assert(inherits(passed_formula, "formula"))
    environment(passed_formula) <- parent_frame

    ## resolve indicator function
    ##  allows for indicators
    ##  outside of {talib} provided the function has a .plotly
    ##  method. This might be a bad idea at this stage, and at any
    ##  stage really as {talib} can be added to the dependency list
    ##  for dispatching.
    ##
    ## TODO: Consider rewriting this section. It works but
    ##       at what cost?
    .f_expression <- substitute(.f); pre_args <- list()

    if (!is.call(.f_expression)) {
      ## fallback value
      f <- match.fun(eval.parent(substitute(.f)))
    } 
    
    if (is.call(.f_expression)) {

      ## get expression
      head <- .f_expression[[1L]]

      if (is.symbol(head)) {

        f <- get(
          x = as.character(head), 
          envir = parent_frame, 
          mode = "function"
        )

      } else {

        if (is.call(head) && as.character(head[[1L]]) %in% c("::", ":::")) {
          
          pkg <- as.character(head[[2L]]); fun <- as.character(head[[3L]])

          f <- if (as.character(head[[1L]]) == "::") {
            getExportedValue(pkg, fun)
          } else {
            get(fun, envir = asNamespace(pkg), mode = "function")
          } 

        } else {

          f <- eval(head, envir = parent_frame)

        }

      }

      pre_args <- as.list(.f_expression)[-1L]


    }

    ## resolve arguments
    dots_mf <- as.list(
      substitute(list(...))
    )[-1L]

    ## check if data has been passed
    ## extract if not
    elt_names <- names(dots_mf)
    if (is.null(elt_names)) {
      elt_names <- rep("", length(dots_mf))
    }

    if (!("data" %in% elt_names)) {
      ## get the plotting environment
      ## temporarily and extract the data
      .env <- get0(".plotting_environment", inherits = TRUE)

      if (is.null(.env) || is.null(.env$x)) {
        stop(
          "No 'data' provided bla bla."
        )
      }

      dots_mf$data <- .env$x

    } 

    ## resolve series
    ## based on formula
    ## was mf
    series <- do.call(
      what = model.frame, 
      args = c(list(formula = passed_formula), dots_mf), 
      envir = parent_frame
    )
  
    ## get plotting environment
    .plotting_environment <- get0(
      x = ".plotting_environment", 
      inherits = TRUE
      )

    if (is.null(.plotting_environment) || is.null(.plotting_environment$main)) {
      ## if there is no main plot
      ## we construct an empty plot to display only
      .plotting_environment$main <- .chart_layout(
        x = plotly::plotly_empty(),
        title_text = "fisk"
      )

    }
    
    ## extract plto
    .plot <- .plotting_environment$main

    .output <- do.call(
      f, 
      c(list(.plot), 
      pre_args, 
      list(.series = series)), 
      envir = parent_frame
    )

    if (inherits(.output, "plotly")) {
      # Build a flat panel list
      panels <- c(list(.plotting_environment$main), .plotting_environment$sub)

      # HARD CHECKS: every element must be a plotly htmlwidget
      is_plotly <- vapply(panels, function(p) inherits(p, "plotly"), logical(1))
      if (!all(is_plotly)) {
        bad <- which(!is_plotly)
        stop(sprintf("Non-plotly passed to subplot at index/indices: %s",
                    paste(bad, collapse = ", ")), call. = FALSE)
      }

      k <- length(panels)
      h_main  <- getOption("talib.chart.main", default = 0.7)
      heights <- if (k > 1) c(h_main, rep((1 - h_main)/(k - 1), k - 1)) else 1

      # IMPORTANT: pass ONLY the panels as the first argument;
      # layout args follow, so none of them can be mis-parsed as plots
      fig <- plotly::subplot(
        panels,
        nrows  = k,
        shareX = TRUE,
        margin  = 0.02,
        heights = heights
      )

      .plotting_environment$chart <- fig
      return(fig)
    }
    
  .output
}