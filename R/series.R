## script: series
## Internal column-resolution layer used by every ta_* indicator.
## Centralises formula handling, default-formula fallback, and the
## matrix -> data.frame coercion so wrappers stay thin.

#' Resolve indicator inputs (internal generic)
#'
#' All `ta_*` wrappers route through `series()` to produce the data
#' frame that the C layer consumes. The [formula][series.formula()]
#' method is the main path; the [ggplot][series.ggplot()] and
#' [plotly][series.plotly()] methods exist so `chart() + indicator()`
#' pipelines reuse the same dispatch.
#'
#' Not part of the public API - call the indicator functions instead.
#' Effectively a thin wrapper around [stats::model.frame()].
#'
#' @param x Dispatch target: a `formula`, `ggplot`, or `plotly` object.
#'   May be omitted by the caller, in which case `default_formula` is
#'   substituted in so dispatch always has a real target.
#' @param default_formula The indicator's default formula
#'   (e.g. `~close`, `~high + low + close`). Used as the fallback for
#'   `x` and as the minimum-length check in [series.formula()].
#' @param ... Forwarded to the dispatched method - typically `data`
#'   plus optional `subset` for [stats::model.frame()].
#'
#' @return A data frame holding the columns required by the indicator,
#'   optionally subset per the formula.
#' @noRd
series <- function(
	x,
	default_formula,
	...
) {
	## Callers may omit `x` when they want the default formula used
	## wholesale (e.g. indicator(RSI, data = df) with no cols). Populate
	## `x` early so dispatch always has a real target.
	if (missing(x)) {
		x <- default_formula
	}

	UseMethod("series", x)
}

#' Chart-pipeline entry for ggplot backends. Resolves `formula` against
#' `default_formula` and delegates to [.series_chart_dispatch()].
#'
#' @param x The active `ggplot` chart object dispatched on.
#' @param default_formula The indicator's default formula (e.g.
#'   `~close`).
#' @param formula Optional explicit column formula; falls back to
#'   `default_formula` when missing.
#' @param ... Quoted by the dispatcher and forwarded to
#'   [stats::model.frame()] - typically `data` and optional `subset`.
#' @noRd
#' @export
series.ggplot <- function(
	x,
	default_formula,
	formula,
	...
) {
	if (missing(formula)) {
		formula <- default_formula
	}
	.series_chart_dispatch(
		x = x,
		default_formula = default_formula,
		formula = formula,
		...
	)
}

#' Chart-pipeline entry for plotly backends. Mirror of
#' [series.ggplot()].
#'
#' @param x The active `plotly` chart object dispatched on.
#' @param default_formula The indicator's default formula (e.g.
#'   `~close`).
#' @param formula Optional explicit column formula; falls back to
#'   `default_formula` when missing.
#' @param ... Quoted by the dispatcher and forwarded to
#'   [stats::model.frame()] - typically `data` and optional `subset`.
#' @noRd
#' @export
series.plotly <- function(
	x,
	default_formula,
	formula,
	...
) {
	if (missing(formula)) {
		formula <- default_formula
	}
	.series_chart_dispatch(
		x = x,
		default_formula = default_formula,
		formula = formula,
		...
	)
}

#' Shared body of [series.ggplot()] / [series.plotly()].
#'
#' Captures `...` as quoted expressions so [stats::model.frame()] can
#' lazily evaluate things like `subset = year(date) > 2020` in the data
#' context rather than in this method's frame. Injects the active
#' chart's data only when the caller did not pass `data` explicitly -
#' this preserves the per-indicator data override
#' (e.g. `chart(ETH); indicator(RSI, data = BTC)` keeps the price panel
#' on ETH while computing RSI on BTC).
#'
#' @param x The chart object dispatched on (`ggplot` / `plotly`).
#' @param default_formula The indicator's default formula.
#' @param formula Resolved column formula (already defaulted by the
#'   caller).
#' @param ... Caller dots; quoted here so [stats::model.frame()] can
#'   evaluate `subset = ...` lazily against the chart's data context.
#' @noRd
.series_chart_dispatch <- function(
	x,
	default_formula,
	formula,
	...
) {
	dots_quoted <- as.list(
		substitute(
			list(...)
		)
	)[-1L]
	dn <- ...names()
	if (length(dots_quoted)) {
		if (is.null(dn)) {
			dn <- rep("", length(dots_quoted))
		}
		names(dots_quoted) <- dn
	} else {
		dots_quoted <- list()
	}

	## Inject the chart's data only when the caller did NOT pass data
	## explicitly. This preserves the per-indicator data override -
	## e.g. chart(ETH); indicator(RSI, data = BTC) computes RSI on BTC
	## while the price panel stays on ETH.
	if (!("data" %in% names(dots_quoted))) {
		state <- .chart_state()
		if (is.null(state) || is.null(state$x)) {
			stop(
				sprintf(
					"series.%s(): no active chart found. ",
					class(x)[1L]
				),
				"Call chart() in the same frame before adding indicators.",
				call. = FALSE
			)
		}
		dots_quoted$data <- state$x
	}

	output <- as.data.frame(
		do.call(
			series.formula,
			c(
				list(x = formula, default_formula = default_formula),
				dots_quoted
			),
			quote = FALSE
		)
	)

	attr(output, "subset") <- eval(dots_quoted$subset)
	output
}

#' Formula method - the main column-resolution path.
#'
#' Validates that an explicit `x` covers at least the variables
#' expected by `default_formula`, fast-coerces plain numeric matrices
#' via the C helper in `src/dataframe.c`, defers classed inputs (xts,
#' zoo, tibble, ...) to [as.data.frame()] for proper method dispatch,
#' then builds the model frame. Skips [stats::model.frame()] entirely
#' when `...` is empty - a small allocation win on the common
#' bare-data path.
#'
#' @param x A `formula` selecting OHLCV columns (e.g. `~close`,
#'   `~high + low + close`). Falls back to `default_formula` when
#'   missing - the generic populates `x`, but `UseMethod()` re-invokes
#'   with the original args, so the missing check has to repeat here.
#' @param default_formula The indicator's default formula. Sets the
#'   minimum acceptable length for an explicit `x`.
#' @param data A data frame, plain numeric matrix, or any object with
#'   an [as.data.frame()] method.
#' @param ... Forwarded to [stats::model.frame()] - typically `subset`.
#' @noRd
#' @export
series.formula <- function(
	x,
	default_formula,
	data,
	...
) {
	## UseMethod re-invokes the method with the *original* arguments,
	## so a missing `x` in the generic stays missing here even though
	## the generic assigned it. Re-resolve before touching `x`.
	if (missing(x)) {
		x <- default_formula
	}

	## An explicit formula must cover at least the variables expected by
	## the indicator's default. A longer formula is allowed - downstream
	## code only consumes what it needs.
	formula_length <- length(all.vars(x))
	default_length <- length(all.vars(default_formula))

	assert(
		x = formula_length >= default_length,
		call = sys.call(sys.parent()),
		paste0("Expected 'cols' length to be ", default_length, "."),
		paste0("Got length ", formula_length, "."),
		paste0(
			"Uses ",
			paste0("'", all.vars(default_formula), "'", collapse = ", "),
			" by default."
		)
	)

	## Fast matrix -> data.frame coercion via the C helper in
	## src/dataframe.c. Restricted to *plain* numeric matrices: an
	## explicit class (xts, zoo, tibble, ...) is left to as.data.frame
	## so the dispatch system picks the correct coercion method.
	if (
		is.matrix(data) &&
			is.null(oldClass(data)) &&
			typeof(data) %in% c("double", "integer")
	) {
		data <- map_dfr(data)
	} else if (!is.data.frame(data)) {
		## map_dfr only registers methods for plain double / integer
		## matrices, so anything carrying an explicit class (xts, zoo,
		## tibble, ...) or a non-numeric type has to go through
		## as.data.frame so its method-dispatched coercion runs.
		data <- as.data.frame(data)
	}

	assert_column_names(
		formula = x,
		available_variables = colnames(data)
	)

	dots_quoted <- as.list(substitute(list(...)))[-1L]

	if (length(dots_quoted) == 0L) {
		output <- data[, all.vars(x), drop = FALSE]
	} else {
		output <- do.call(
			stats::model.frame,
			c(list(formula = x, data = data), dots_quoted),
			quote = FALSE
		)
	}

	attr(output, "subset") <- eval(dots_quoted$subset)

	output
}
