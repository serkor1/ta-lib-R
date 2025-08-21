#' @export
indicator <- function(
  .f,
  .var,
  ...
) {
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
  .f_expression <- substitute(.f)
  pre_args <- list()

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
        pkg <- as.character(head[[2L]])
        fun <- as.character(head[[3L]])

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

  ## construct series
  ## based on .var
  ##
  ## NOTE: The series is passed
  ##       as a data.frame to dispacther
  ##       disected, calculate indicator
  ##       then converted to a data.frame again
  #
  ##       This is not optimal.
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

  ## resolve plotting the
  ## indicator and determine
  ## functions
  .plot <- .plotting_environment$main

  .output <- do.call(
    what = f,
    args = c(
      ## first argument
      ## for S3 dispatching
      list(.plot),

      ## args for the indicator
      ## function itself
      pre_args,

      ## the series passed
      ## via ellipsis
      list(.series = series)
    ),

    envir = parent_frame
  )

  ## handle plotly object
  ## safely and securely
  if (inherits(.output, "plotly")) {
    ## construct panel
    ## list for the subplots
    panels <- c(
      ## main panel
      list(.plotting_environment$main),
      ## sub panel
      .plotting_environment$sub
    )

    ## check for shenanigans
    ## of some sort
    is_plotly <- vapply(
      X = panels,
      FUN = function(p) inherits(p, "plotly"),
      FUN.VALUE = logical(1)
    )

    assert(
      all(is_plotly)
    )

    # if (!all(is_plotly)) {
    #   bad <- which(!is_plotly)
    #   stop(
    #     sprintf(
    #       "Non-plotly passed to subplot at index/indices: %s",
    #       paste(bad, collapse = ", ")
    #     ),
    #     call. = FALSE
    #   )
    # }

    ## construct subplot
    ## based on existing environment
    ##
    ## NOTE: this was originally
    ##       handled via dispatchers
    ##       but everything is rebuilt
    ##       recursively, so it makes better
    ##       sense to just "handle it here"
    number_of_panels <- length(panels)
    main_panel_height <- getOption(
      "talib.chart.main",
      default = 0.7
    )

    heights <- if (number_of_panels > 1) {
      ## calculate divisor
      ## also used for lenght.out
      ## values
      divisor <- number_of_panels - 1

      c(
        main_panel_height,
        rep(
          x = (1 - main_panel_height) / (divisor),
          divisor
        )
      )
    } else {
      ## The main panel will
      ## be the entire thing
      ## if only one panel is passed
      1
    }

    ## construct the subplot
    ## sequentially
    ##
    ## NOTE: Additional options and
    ##       configurations could be passed
    ##       here
    fig <- plotly::subplot(
      panels,
      nrows = k,
      shareX = TRUE,
      margin = 0.02,
      heights = heights
    )

    ## at this stage it is unclear
    ## whether .$chart is actually needed
    ## because plotly is a b*tch to work with
    ## when it comes to subplots.
    ##
    ## TODO: Check if its possible to "update"
    ##       the charts incrementally. Might be something that
    ##       can be done downstream
    .plotting_environment$chart <- fig

    return(fig)
  }

  ## fallback to cases
  ## where it is NOT a plotly
  ## object. For development purposes
  ## mainly.
  .output
}
