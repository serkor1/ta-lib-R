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

## assert_plotly_object(x): assert that `x` is a <plotly> OBJECT.
## Renamed from assert_plotly() for symmetry with assert_plotly_pkg()
## (which checks that the plotly PACKAGE is installed).
assert_plotly_object <- function(x) {
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

	## Non-syntactic names (containing spaces, hyphens, starting with a
	## digit, etc.) survive as.name() but break downstream in ggplot2's
	## aes() via the !!as.name() rewrite used by the .ggplot methods.
	## Fail fast here with a clear message so the user isn't hunting
	## through tidyeval stack traces.
	syntactic <- make.names(passed_variables)
	non_syntactic <- passed_variables[syntactic != passed_variables]
	if (length(non_syntactic) > 0L) {
		assert(
			x = FALSE,
			call = sys.call(sys.parent(n = 2)),
			"Column names must be syntactically valid R names.",
			paste0(
				"Non-syntactic names detected: ",
				paste0("'", non_syntactic, "'", collapse = ", "),
				"."
			),
			paste0(
				"Rename the offending columns (e.g. ",
				"names(x)[names(x) == '",
				non_syntactic[1L],
				"'] <- '",
				make.names(non_syntactic[1L]),
				"') before calling this function."
			)
		)
	}
}

## small base-R replacements - kept internal
## to avoid Imports on utils/stats just for these
.tail <- function(x, n = 1L) {
	len <- length(x)
	if (len == 0L) {
		return(x)
	}
	x[seq.int(max(1L, len - n + 1L), len)]
}

.set_names <- function(x, nm) {
	names(x) <- nm
	x
}

## class related utility
## functions
is.formula <- function(x) {
	inherits(x, "formula")
}

is.plotly <- function(x) {
	inherits(x, "plotly")
}

is.ggplot <- function(x) {
	inherits(x, "gg")
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
		C_set_candle_setting,
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
		C_rownames_data_frame,
		x,
		x_names
	)

	return(invisible(NULL))
}

#' @export
set_rownames.matrix <- function(x, x_names) {
	## set the rownames
	.Call(
		C_rownames_matrix,
		x,
		x_names,
		colnames(x)
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

	x <- .Call(C_map_dfr_double, x)

	attr(x, "lookback") <- lookback_attribute

	x
}

#' @export
map_dfr.integer <- function(x) {
	if (!is.matrix(x)) {
		stop("'x' has to be a <matrix>")
	}

	lookback_attribute <- attr(x, "lookback", TRUE)

	x <- .Call(C_map_dfr_integer, x)
	attr(x, "lookback") <- lookback_attribute

	x
}
