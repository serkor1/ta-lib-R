#' @export
#' @family Pattern Recognition
#'
#' @title Morning Doji Star
#' @templateVar .title Morning Doji Star
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun morning_doji_star
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
morning_doji_star <- function(
	x,
	cols,
	eps = 0,
	...
) {
	UseMethod("morning_doji_star")
}

#' @export
#' @usage NULL
#' @rdname morning_doji_star
#'
#' @aliases morning_doji_star
CDLMORNINGDOJISTAR <- morning_doji_star

#' @usage NULL
#' @aliases morning_doji_star
#'
#' @export
morning_doji_star.default <- function(
	x,
	cols,
	eps = 0,
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
	x_names <- rownames(x)

	## calculate indicator and
	## return as data.frame
	x <- as.matrix(
		.Call(
			"impl_ta_CDLMORNINGDOJISTAR",
			constructed_series[[1]],
			constructed_series[[2]],
			constructed_series[[3]],
			constructed_series[[4]],
			eps = eps,
			normalize
		)
	)

	## add column name
	colnames(x) <- "CDLMORNINGDOJISTAR"

	## readd rownames
	rownames(x) <- x_names

	## return indicator
	x
}

#' @usage NULL
#' @aliases morning_doji_star
#'
#' @export
morning_doji_star.data.frame <- function(
	x,
	cols,
	eps = 0,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases morning_doji_star
#'
#' @export
morning_doji_star.matrix <- function(
	x,
	cols,
	eps = 0,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases morning_doji_star
#'
#' @export
morning_doji_star.plotly <- function(
	x,
	cols,
	eps = 0,
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
	constructed_indicator <- morning_doji_star(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		eps = eps
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
		pattern_name = "morning_doji_star",
		agnostic = FALSE
	)

	plotly_object
}
