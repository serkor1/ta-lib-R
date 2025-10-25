#' @export
#' @family Pattern Recognition
#'
#' @title Closing Marubozu
#' @templateVar .title Closing Marubozu
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun closing_marubozu
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
closing_marubozu <- function(
	x,
	cols,
	...
) {
	UseMethod("closing_marubozu")
}

#' @export
#' @usage NULL
#' @rdname closing_marubozu
#'
#' @aliases closing_marubozu
CDLCLOSINGMARUBOZU <- closing_marubozu

#' @usage NULL
#' @aliases closing_marubozu
#'
#' @export
closing_marubozu.default <- function(
	x,
	cols,
	...
) {
	## get normalization option
	normalize <- as.logical(
		getOption("talib.normalize", TRUE)
	)

	## validate 'cols'-argument
	## if explicitly passed
	if (!missing(cols)) {
		assert_formula(cols)
	}

	## construct series
	## from input
	constructed_series <- series(
		x = cols,
		default = ~ open + high + low + close,
		data = x,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- rownames(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- as.matrix(
		.Call(
			"impl_ta_CDLCLOSINGMARUBOZU",
			constructed_series[[1]],
			constructed_series[[2]],
			constructed_series[[3]],
			constructed_series[[4]],
			normalize
		)
	)

	## add column name
	colnames(x) <- "CDLCLOSINGMARUBOZU"

	## readd rownames
	rownames(x) <- x_names

	## return indicator
	x
}

#' @usage NULL
#' @aliases closing_marubozu
#'
#' @export
closing_marubozu.data.frame <- function(
	x,
	cols,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases closing_marubozu
#'
#' @export
closing_marubozu.matrix <- function(
	x,
	cols,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases closing_marubozu
#'
#' @export
closing_marubozu.plotly <- function(
	x,
	cols,
	...
) {
	## check that input value
	## 'x' is <plotly>-object
	assert_plotly(x)

	## check that input value
	## 'cols' is a <formula>-objet
	if (!missing(cols)) {
		assert_formula(cols)
	}

	## construct series from
	## {plotly}-object
	constructed_series <- series(
		x = x,
		formula = cols,
		default = ~ open + high + low + close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- closing_marubozu(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		)
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {plotly}-object
	plotly_object <- .plotting_environment[["main"]] <- pattern(
		p = .plotting_environment[["main"]],
		x = constructed_indicator,
		high = constructed_series[[2]],
		low = constructed_series[[3]],
		pattern_name = "closing_marubozu",
		agnostic = TRUE
	)

	plotly_object
}
