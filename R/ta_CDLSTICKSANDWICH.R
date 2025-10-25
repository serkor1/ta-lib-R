#' @export
#' @family Pattern Recognition
#'
#' @title Stick Sandwich
#' @templateVar .title Stick Sandwich
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun stick_sandwich
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
stick_sandwich <- function(
	x,
	cols,
	...
) {
	UseMethod("stick_sandwich")
}

#' @export
#' @usage NULL
#' @rdname stick_sandwich
#'
#' @aliases stick_sandwich
CDLSTICKSANDWICH <- stick_sandwich

#' @usage NULL
#' @aliases stick_sandwich
#'
#' @export
stick_sandwich.default <- function(
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
			"impl_ta_CDLSTICKSANDWICH",
			constructed_series[[1]],
			constructed_series[[2]],
			constructed_series[[3]],
			constructed_series[[4]],
			normalize
		)
	)

	## add column name
	colnames(x) <- "CDLSTICKSANDWICH"

	## readd rownames
	rownames(x) <- x_names

	## return indicator
	x
}

#' @usage NULL
#' @aliases stick_sandwich
#'
#' @export
stick_sandwich.data.frame <- function(
	x,
	cols,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases stick_sandwich
#'
#' @export
stick_sandwich.matrix <- function(
	x,
	cols,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases stick_sandwich
#'
#' @export
stick_sandwich.plotly <- function(
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
	constructed_indicator <- stick_sandwich(
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
		pattern_name = "stick_sandwich",
		agnostic = FALSE
	)

	plotly_object
}
