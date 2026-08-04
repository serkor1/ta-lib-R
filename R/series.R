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
#'   May be omitted by the caller, in which case `formula.default` is
#'   substituted in so dispatch always has a real target.
#' @param formula.default The indicator's default formula
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
	formula, ## passed formula
	formula.default, ## default formula
	...
) {
	UseMethod("series", x)
}

#' @export
series.default <- function(
	x,
	formula,
	formula.default,
	...
) {
	## classed inputs (zoo, tibble-likes, ...) defer to
	## as.data.frame() for proper method dispatch
	series(
		x = as.data.frame(x),
		formula = formula,
		formula.default = formula.default,
		...
	)
}

#' Chart-pipeline entry for ggplot backends. Resolves `formula` against
#' `formula.default` and delegates to [.series_chart_dispatch()].
#'
#' @param x The active `ggplot` chart object dispatched on.
#' @param formula.default The indicator's default formula (e.g.
#'   `~close`).
#' @param formula Optional explicit column formula; falls back to
#'   `formula.default` when missing.
#' @param ... Quoted by the dispatcher and forwarded to
#'   [stats::model.frame()] - typically `data` and optional `subset`.
#' @noRd
#' @export
series.ggplot <- function(
	x,
	formula,
	formula.default,
	...
) {
	if (missing(formula)) {
		formula <- formula.default
	}
	.series_chart_dispatch(
		x = x,
		formula.default = formula.default,
		formula = formula,
		...
	)
}

#' Chart-pipeline entry for plotly backends. Mirror of
#' [series.ggplot()].
#'
#' @param x The active `plotly` chart object dispatched on.
#' @param formula.default The indicator's default formula (e.g.
#'   `~close`).
#' @param formula Optional explicit column formula; falls back to
#'   `formula.default` when missing.
#' @param ... Quoted by the dispatcher and forwarded to
#'   [stats::model.frame()] - typically `data` and optional `subset`.
#' @noRd
#' @export
series.plotly <- function(
	x,
	formula,
	formula.default,
	...
) {
	if (missing(formula)) {
		formula <- formula.default
	}
	.series_chart_dispatch(
		x = x,
		formula.default = formula.default,
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
#' @param formula.default The indicator's default formula.
#' @param formula Resolved column formula (already defaulted by the
#'   caller).
#' @param ... Caller dots; quoted here so [stats::model.frame()] can
#'   evaluate `subset = ...` lazily against the chart's data context.
#' @noRd
.series_chart_dispatch <- function(
	x,
	formula,
	formula.default,
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

	data_arg <- dots_quoted$data
	dots_quoted$data <- NULL

	output <- as.data.frame(
		do.call(
			series,
			c(
				list(
					x = data_arg,
					formula = formula,
					formula.default = formula.default
				),
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
#' expected by `formula.default`, fast-coerces plain numeric matrices
#' via the C helper in `src/dataframe.c`, defers classed inputs (xts,
#' zoo, tibble, ...) to [as.data.frame()] for proper method dispatch,
#' then builds the model frame. Skips [stats::model.frame()] entirely
#' when `...` is empty - a small allocation win on the common
#' bare-data path.
#'
#' @param x A `formula` selecting OHLCV columns (e.g. `~close`,
#'   `~high + low + close`). Falls back to `formula.default` when
#'   missing - the generic populates `x`, but `UseMethod()` re-invokes
#'   with the original args, so the missing check has to repeat here.
#' @param formula.default The indicator's default formula. Sets the
#'   minimum acceptable length for an explicit `x`.
#' @param data A data frame, plain numeric matrix, or any object with
#'   an [as.data.frame()] method.
#' @param ... Forwarded to [stats::model.frame()] - typically `subset`.
#' @noRd
#' @export
series.data.frame <- function(
	x,
	formula,
	formula.default,
	...
) {
	# ## UseMethod re-invokes the method with the *original* arguments,
	# ## so a missing `x` in the generic stays missing here even though
	# ## the generic assigned it. Re-resolve before touching `x`.
	if (missing(formula)) {
		formula <- formula.default
	}

	## An explicit formula must cover at least the variables expected by
	## the indicator's default. A longer formula is allowed - downstream
	## code only consumes what it needs.
	formula_length <- length(all.vars(formula))
	default_length <- length(all.vars(formula.default))

	assert(
		x = formula_length >= default_length,
		call = sys.call(sys.parent()),
		paste0("Expected 'cols' length to be ", default_length, "."),
		paste0("Got length ", formula_length, "."),
		paste0(
			"Uses ",
			paste0("'", all.vars(formula.default), "'", collapse = ", "),
			" by default."
		)
	)

	assert_column_names(
		formula = formula,
		available_variables = colnames(x)
	)

	dots_quoted <- as.list(substitute(list(...)))[-1L]

	if (length(dots_quoted) == 0L) {
		output <- x[, all.vars(formula), drop = FALSE]
	} else {
		output <- do.call(
			stats::model.frame,
			c(list(formula = formula, data = x), dots_quoted),
			quote = FALSE
		)
	}

	attr(output, "subset") <- eval(dots_quoted$subset)

	output
}

#' @export
series.matrix <- function(
	x,
	formula,
	formula.default,
	...
) {
	## convert to <data.frame>
	## and pass into series
	x <- map_dfr(x)

	series(
		x = x,
		formula = formula,
		formula.default = formula.default
	)
}

#' @export
series.xts <- function(
	x,
	formula,
	formula.default,
	...
) {
	## reclass 'x' so downstream can
	## can handle the output
	class(x) <- c(
		class(x),
		"ta_series"
	)

	## fast-track univariate input: a single-column <xts>
	## is consumed as-is when the indicator expects a single
	## series, regardless of its column name
	if (missing(formula)) {
		if (NCOL(x) == 1L && length(all.vars(formula.default)) == 1L) {
			return(x)
		}

		## if the formula is not passed
		## it should be replaced by the default
		formula <- formula.default
	}

	if (...length()) {
		warning(
			"'...' is passed but is unused for <xts>.",
			call. = FALSE
		)
	}

	## an explicit formula must cover at least the variables
	## expected by the indicator's default. A longer formula is
	## allowed - downstream code only consumes what it needs.
	formula_length <- length(all.vars(formula))
	default_length <- length(all.vars(formula.default))

	assert(
		x = formula_length >= default_length,
		call = sys.call(sys.parent()),
		paste0("Expected 'cols' length to be ", default_length, "."),
		paste0("Got length ", formula_length, "."),
		paste0(
			"Uses ",
			paste0("'", all.vars(formula.default), "'", collapse = ", "),
			" by default."
		)
	)

	passed_variables <- all.vars(formula)
	available_variables <- colnames(x)

	lowered_passed <- tolower(passed_variables)
	lowered_available <- tolower(available_variables)

	## match matrix: one row per formula variable, one column
	## per <xts> column. Exact name matches win over
	## quantmod-style suffix matches (close -> TICKER.Close) so
	## a plain 'Close' column is preferred over 'Adj.Close';
	## columns are resolved in formula order because the C layer
	## consumes them positionally
	exact_hits <- outer(
		lowered_passed,
		lowered_available,
		`==`
	)

	suffix_hits <- outer(
		paste0(".", lowered_passed),
		lowered_available,
		function(suffix, name) endsWith(name, suffix)
	)

	suffix_hits[rowSums(exact_hits) > 0L, ] <- FALSE

	hits <- exact_hits | suffix_hits
	matches <- rowSums(hits)

	assert(
		x = all(matches > 0L),
		call = sys.call(sys.parent()),
		paste(
			"Expected to find columns",
			paste0("'", passed_variables, "'", collapse = ", ")
		),
		paste0(
			"available columns: ",
			paste0("'", available_variables, "'", collapse = ", ")
		)
	)

	assert(
		x = all(matches == 1L),
		call = sys.call(sys.parent()),
		paste(
			"Ambiguous columns",
			paste0("'", passed_variables[matches > 1L], "'", collapse = ", "),
			"."
		),
		paste0(
			"Matches: ",
			paste0(
				"'",
				available_variables[
					colSums(hits[matches > 1L, , drop = FALSE]) > 0L
				],
				"'",
				collapse = ", "
			),
			"."
		)
	)

	## the single TRUE per row is the resolved column
	identified_columns <- max.col(hits, ties.method = "first")

	x[, identified_columns, drop = FALSE]
}
