## script: utility functions
## for the small essential tasks
##
## assert input values
## with and without wrappers
assert <- function(
	x,
	call = sys.call(),
	...
) {
	## exit the function if x is
	## TRUE
	if (x) {
		return(invisible(TRUE))
	}

	system_message <- if (...length()) {
		paste(...)
	} else {
		"Assertion failed"
	}

	stop(
		simpleError(
			message = system_message,
			call = call
		)
	)
}

assert_formula <- function(x) {
	## NOTE: this **could** potentially
	##       be used in
	## assert that it is a formula
	##
	assert(
		x = is.formula(x),
		call = sys.call(sys.parent()),
		"Expected",
		paste0("'", substitute(x), "'"),
		"as <formula>.",
		"Got",
		paste0(
			"<",
			class(x),
			">."
		)
	)
}

assert_plotly <- function(x) {
	assert(
		x = is.plotly(x),
		call = sys.call(sys.parent()),
		"Expected",
		paste0("'", substitute(x), "'"),
		"as <plotly>.",
		"Got",
		paste0(
			"<",
			class(x),
			">."
		)
	)
}

assert_ohlcv <- function(x) {
	assert(
		x = is.ohlcv(x),
		call = sys.call(sys.parent()),
		"Expected",
		paste0("'", substitute(x), "'"),
		"as <ohlcv>.",
		"Got",
		paste0("<", class(x)[1L], ">.")
	)
}

assert_column_names <- function(formula, available_variables) {
	## this assert function will give an error
	## if the variables are not found. If it finds
	## similar variables, it will print those.
	##
	## formula is the ultimate truth

	## passed variables
	passed_variables <- all.vars(formula)
	identified_variables <- intersect(
		passed_variables,
		available_variables
	)

	all_identified <- all(passed_variables %in% identified_variables)
	if (!all_identified) {
		## identify similar variables so the user
		## has an idea why it fails
		similar_variables <- grep(
			pattern = paste(passed_variables, collapse = "|"),
			x = available_variables,
			value = TRUE,
			ignore.case = TRUE
		)

		assert(
			x = all_identified,
			call = sys.call(sys.parent(n = 2)),
			paste(
				"Expected to find columns",
				paste0("'", passed_variables, "'", collapse = ", ")
			),
			if (!identical(character(0), similar_variables)) {
				paste0(
					"similar columns found: ",
					paste0("'", similar_variables, "'", collapse = ", ")
				)
			}
		)
	}
}

## class related utility
## functions
is.formula <- function(x) {
	inherits(x, "formula")
}

is.plotly <- function(x) {
	inherits(x, "plotly")
}

## extract input name
input_name <- function(x) {
	if (is.call(x) && as.character(x[[1L]]) %in% c("::", ":::")) {
		x <- x[[3L]]
	}
	deparse(x)
}

## check for args
has_arg <- function(name) {
	## shamelessly stolen from
	## {methods}
	aname <- as.character(substitute(name))
	fnames <- names(
		formals(
			sys.function(sys.parent())
		)
	)

	if (is.na(match(aname, fnames))) {
		if (is.na(match("...", fnames))) {
			FALSE
		} else {
			dotsCall <- eval(quote(substitute(list(...))), sys.parent())
			!is.na(match(aname, names(dotsCall)))
		}
	} else {
		eval(substitute(!missing(name)), sys.frame(sys.parent()))
	}
}

## candle settings

## general setup
impl_candle_setting <- function(
	setting = 1L,
	range_type = 0L,
	N,
	alpha
) {
	.Call(
		"set_candle_setting",
		as.integer(setting),
		as.integer(range_type),
		as.integer(N),
		as.double(alpha)
	)
}

candlestick_setting <- function() {
	## 0 RealBody, 1 HighLow, 2 Shadows
	## BodyLong
	impl_candle_setting(
		setting = 0L,
		range_type = 0L,
		N = getOption("talib.BodyLong.N", 10L),
		alpha = getOption("talib.BodyLong.alpha", 1.0)
	)
	## BodyVeryLong
	impl_candle_setting(
		setting = 1L,
		range_type = 0L,
		N = getOption("talib.BodyVeryLong.N", 10L),
		alpha = getOption("talib.BodyVeryLong.alpha", 3.0)
	)
	## BodyShort
	impl_candle_setting(
		setting = 2L,
		range_type = 0L,
		N = getOption("talib.BodyShort.N", 10L),
		alpha = getOption("talib.BodyShort.alpha", 1.0)
	)
	## BodyDoji
	impl_candle_setting(
		setting = 3L,
		range_type = 1L,
		N = getOption("talib.BodyDoji.N", 10L),
		alpha = getOption("talib.BodyDoji.alpha", 0.1)
	)
	## ShadowLong
	impl_candle_setting(
		setting = 4L,
		range_type = 0L,
		N = getOption("talib.ShadowLong.N", 0L),
		alpha = getOption("talib.ShadowLong.alpha", 1.0)
	)
	## ShadowVeryLong
	impl_candle_setting(
		setting = 5L,
		range_type = 0L,
		N = getOption("talib.ShadowVeryLong.N", 0L),
		alpha = getOption("talib.ShadowVeryLong.alpha", 2.0)
	)
	## ShadowShort
	impl_candle_setting(
		setting = 6L,
		range_type = 2L,
		N = getOption("talib.ShadowShort.N", 10L),
		alpha = getOption("talib.ShadowShort.alpha", 1.0)
	)
	## ShadowVeryShort
	impl_candle_setting(
		setting = 7L,
		range_type = 1L,
		N = getOption("talib.ShadowVeryShort.N", 10L),
		alpha = getOption("talib.ShadowVeryShort.alpha", 0.1)
	)
	## Near
	impl_candle_setting(
		setting = 8L,
		range_type = 1L,
		N = getOption("talib.Near.N", 5L),
		alpha = getOption("talib.Near.alpha", 0.2)
	)
	## Far
	impl_candle_setting(
		setting = 9L,
		range_type = 1L,
		N = getOption("talib.Far.N", 5L),
		alpha = getOption("talib.Far.alpha", 0.6)
	)
	## Equal
	impl_candle_setting(
		setting = 10L,
		range_type = 1L,
		N = getOption("talib.Equal.N", 5L),
		alpha = getOption("talib.Equal.alpha", 0.05)
	)

	invisible(NULL)
}


## rownaming
set_rownames <- function(x, x_names) {
	UseMethod("set_rownames")
}

#' @export
set_rownames.data.frame <- function(x, x_names) {
	## set the rownames
	.Call(
		"rownames_data_frame",
		x,
		x_names,
		PACKAGE = "talib"
	)

	return(invisible(NULL))
}

#' @export
set_rownames.matrix <- function(x, x_names) {
	## set the rownames
	.Call(
		"rownames_matrix",
		x,
		x_names,
		colnames(x),
		PACKAGE = "talib"
	)

	return(invisible(NULL))
}

## map <matrix> to <data.frames>
map_dfr <- function(x) {
	UseMethod("map_dfr")
}

#' @export
map_dfr.double <- function(x) {
	if (!is.matrix(x)) {
		stop("'x' has to be a <matrix>")
	}

	lookback_attribute <- attr(x, "lookback", TRUE)

	x <- .Call(
		"map_dfr_double",
		x
	)

	attr(x, "lookback") <- lookback_attribute

	x
}

#' @export
map_dfr.integer <- function(x) {
	if (!is.matrix(x)) {
		stop("'x' has to be a <matrix>")
	}

	lookback_attribute <- attr(x, "lookback", TRUE)

	x <- .Call(
		"map_dfr_integer",
		x
	)
	attr(x, "lookback") <- lookback_attribute

	x
}

## NA handling utilities
## for the na.rm parameter
##
## strip_na: remove rows with NAs
## and track their positions
strip_na <- function(series, x_names) {
	complete <- complete.cases(series)

	if (all(complete)) {
		return(
			list(
				series = series,
				x_names = x_names,
				na_idx = NULL,
				n_original = NULL
			)
		)
	}

	list(
		series = series[complete, , drop = FALSE],
		x_names = if (!is.null(x_names)) x_names[complete] else NULL,
		na_idx = which(!complete),
		n_original = nrow(series),
		x_names_all = x_names
	)
}

## reexpand_na: re-insert NA rows
## at their original positions
reexpand_na <- function(result, na_info) {
	if (is.null(na_info$na_idx)) {
		return(result)
	}

	n <- na_info$n_original
	na_idx <- na_info$na_idx
	x_names_all <- na_info$x_names_all

	if (is.matrix(result)) {
		out <- matrix(
			if (is.integer(result)) NA_integer_ else NA_real_,
			nrow = n,
			ncol = ncol(result)
		)
		colnames(out) <- colnames(result)
		out[-na_idx, ] <- result

		## preserve lookback attribute
		lookback <- attr(result, "lookback", TRUE)
		if (!is.null(lookback)) {
			attr(out, "lookback") <- lookback
		}

		## restore rownames
		if (!is.null(x_names_all)) {
			rownames(out) <- x_names_all
		}

		out
	} else {
		## numeric vector
		out <- rep(NA_real_, n)
		out[-na_idx] <- result
		out
	}
}

## vector-level NA strip/reexpand
strip_na_vector <- function(x) {
	na_idx <- which(is.na(x))

	if (length(na_idx) == 0L) {
		return(
			list(
				x = x,
				na_idx = NULL,
				n_original = NULL
			)
		)
	}

	list(
		x = x[!is.na(x)],
		na_idx = na_idx,
		n_original = length(x)
	)
}

reexpand_na_vector <- function(result, na_info) {
	if (is.null(na_info$na_idx)) {
		return(result)
	}

	n <- na_info$n_original

	if (is.matrix(result)) {
		out <- matrix(
			if (is.integer(result)) NA_integer_ else NA_real_,
			nrow = n,
			ncol = ncol(result)
		)
		colnames(out) <- colnames(result)
		out[-na_info$na_idx, ] <- result
		out
	} else {
		out <- rep(NA_real_, n)
		out[-na_info$na_idx] <- result
		out
	}
}
