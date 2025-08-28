#' @export
indicator <- function(
  FUN,
  cols,
  ...
) {
  parent_frame <- parent.frame()

  has_var <- !missing(cols)
  if (has_var) {
    var_expr <- eval.parent(substitute(cols))
    stopifnot(inherits(var_expr, "formula"))
    environment(var_expr) <- parent_frame
  }

  f_call <- substitute(FUN)
  pre_args <- list()
  if (!is.call(f_call)) {
    f <- match.fun(eval.parent(substitute(FUN)))
  } else {
    head <- f_call[[1L]]
    if (is.symbol(head)) {
      f <- get(as.character(head), envir = parent_frame, mode = "function")
    } else if (is.call(head) && as.character(head[[1L]]) %in% c("::", ":::")) {
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
    pre_args <- as.list(f_call)[-1L]
  }

  # Ensure a base plot for .plotly methods
  .plotting_environment <- get0(".plotting_environment", inherits = TRUE)
  if (is.null(.plotting_environment) || is.null(.plotting_environment$main)) {
    .plotting_environment$main <- .chart_layout(
      x = plotly::plotly_empty(),
      title_text = "fisk"
    )
  }

  .plot <- .plotting_environment$main

  # Build call
  dots <- as.list(substitute(list(...)))[-1L]
  args <- c(list(.plot), pre_args)

  # Only add the formula arg if provided
  if (has_var) {
    f_formals <- try(names(formals(f)), silent = TRUE)
    if (inherits(f_formals, "try-error")) {
      f_formals <- character()
    }
    formula_arg <- if ("cols" %in% f_formals) {
      "cols"
    } else if ("formula" %in% f_formals) {
      "formula"
    } else if ("cols" %in% f_formals) {
      "cols"
    } else {
      "cols"
    }
    args[[formula_arg]] <- var_expr
  }

  out <- do.call(f, c(args, dots), envir = parent_frame)

  if (inherits(out, "plotly")) {
    panels <- c(list(.plotting_environment$main), .plotting_environment$sub)
    stopifnot(all(vapply(
      panels,
      function(p) inherits(p, "plotly"),
      logical(1)
    )))
    n <- length(panels)
    main_h <- getOption("talib.chart.main", 0.7)
    heights <- if (n > 1) c(main_h, rep((1 - main_h) / (n - 1), n - 1)) else 1
    fig <- plotly::subplot(
      panels,
      nrows = n,
      shareX = TRUE,
      margin = 0.02,
      heights = heights
    )
    .plotting_environment$chart <- fig
    return(fig)
  }

  out
}
