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