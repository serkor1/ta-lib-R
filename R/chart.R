#' @export
chart <- function(x, ...) {
  UseMethod(
    "chart"
  )
}

#' @export
chart.default <- function(x, ...) {
  ## convert to data.frame
  data_frame <- as.data.frame(x)

  .plotting_environment$x <- data_frame
  
  ## 1) generate kline
  kline_chart <- plotly::plot_ly(
    data  = data_frame,
    type  = "candlestick",
    open  = ~open,
    close = ~close,
    high  = ~high,
    low   = ~low,
    increasing = list(
      line = list(color = chart.theme()$bull_color, width = 3 - 1.75),
      fillcolor = chart.theme()$bull_color
    ),
    decreasing = list(
      line = list(color = chart.theme()$bear_color, width = 3 - 1.75),
      fillcolor = chart.theme()$bear_color
    ),
    ...
  )

  
  ## 2) store in environment
  ##    to enable chart() call
  .plotting_environment$main <- .chart_layout(
    x = kline_chart,
    title_text = sprintf(
      "<b>Ticker:</b> %s <br><sub><b>Period:</b> %s</sub>",
      deparse(substitute(x)),
      "Period Value"
    )
  )

  ## subplot list
  .plotting_environment$sub <- list()  # list(), not a plotly or other type
.plotting_environment$chart <- NULL


  ## 3) add plot counter
  ##    for subplots
  .plotting_environment$plot_counter <- 1


  .plotting_environment$main 
  
}

#' @export
indicator <- function(
  .f, 
  .var, 
  ...) {

    parent_frame <- parent.frame()

    passed_formula <- eval.parent(substitute(.var))

    if (!inherits(passed_formula, "formula")) {
      stop("`.var` must be a formula.", call. = FALSE)
    }

    environment(passed_formula) <- parent_frame

    f_expr   <- substitute(.f)
    pre_args <- list()
    if (is.call(f_expr)) {
      head <- f_expr[[1L]]
      if (is.symbol(head)) {
        f <- get(as.character(head), envir = parent_frame, mode = "function")
      } else if (is.call(head) && as.character(head[[1L]]) %in% c("::", ":::")) {
        pkg <- as.character(head[[2L]]); fun <- as.character(head[[3L]])
        f <- if (as.character(head[[1L]]) == "::")
          getExportedValue(pkg, fun) else get(fun, envir = asNamespace(pkg), mode = "function")
      } else {
        f <- eval(head, envir = parent_frame)
      }
      pre_args <- as.list(f_expr)[-1L]
    } else {
      f <- match.fun(eval.parent(substitute(.f)))
    }


    dots_mf <- as.list(substitute(list(...)))[-1L]

    dn <- names(dots_mf); if (is.null(dn)) dn <- rep("", length(dots_mf))
    if (!("data" %in% dn)) {
      pe <- get0(".plotting_environment", inherits = TRUE)
      if (!is.null(pe) && !is.null(pe$x)) {
        dots_mf$data <- pe$x         # <<< pass the actual data.frame
      } else if (!is.null(pe) && !is.null(pe$data)) {
        dots_mf$data <- pe$data
      } else {
        stop("No `data` provided and no active chart data found. Call chart(...) first.", call. = FALSE)
      }
    }

    ## model frame
    mf <- do.call(
      what = model.frame, 
      args = c(list(formula = passed_formula), dots_mf), 
      envir = parent_frame
    )
  
    mm_dots <- dots_mf[intersect(names(dots_mf), c("contrasts", "xlev"))]
    mm <- do.call(model.matrix, c(list(object = passed_formula, data = mf), mm_dots), envir = parent_frame)
  
    if (!is.null(colnames(mm)) && "(Intercept)" %in% colnames(mm)) {
      mm <- mm[, setdiff(colnames(mm), "(Intercept)"), drop = FALSE]
    }
  
    series <- if (NCOL(mm) == 1L) {
      as.numeric(mm[, 1L])
    } else {
      mm
    }

    ## 6) fetch active plotly object (first arg for S3)
    .plotting_environment <- get0(".plotting_environment", inherits = TRUE)
    if (is.null(.plotting_environment) || is.null(.plotting_environment$main)) {
       stop("No active plotly chart. Call chart(...) first.", call. = FALSE)
    }
     
    .plot <- .plotting_environment$main

    .output <- do.call(f, c(list(.plot), pre_args, list(.series = series)), envir = parent_frame)

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
  h_main  <- 0.70
  heights <- if (k > 1) c(h_main, rep((1 - h_main)/(k - 1), k - 1)) else 1

  # IMPORTANT: pass ONLY the panels as the first argument;
  # layout args follow, so none of them can be mis-parsed as plots
  fig <- plotly::subplot(
    panels,
    nrows  = k,
    shareX = TRUE,
    margin = 0.02,
    heights = heights
  )

  .plotting_environment$chart <- fig
  return(fig)
}

.output
}