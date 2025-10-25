#' @export
#' @family Pattern Recognition
#'
#' @title Concealing Baby Swallow
#' @templateVar .title Concealing Baby Swallow
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun concealing_baby_swallow
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
concealing_baby_swallow <- function(
	x,
	cols,
	...
) {
	UseMethod("concealing_baby_swallow")
}

#' @export
#' @usage NULL
#' @rdname concealing_baby_swallow
#'
#' @aliases concealing_baby_swallow
CDLCONCEALBABYSWALL <- concealing_baby_swallow

#' @usage NULL
#' @aliases concealing_baby_swallow
#'
#' @export
concealing_baby_swallow.default <- function(
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
			"impl_ta_CDLCONCEALBABYSWALL",
			constructed_series[[1]],
			constructed_series[[2]],
			constructed_series[[3]],
			constructed_series[[4]],
			normalize
		)
	)

	## add column name
	colnames(x) <- "CDLCONCEALBABYSWALL"

	## readd rownames
	rownames(x) <- x_names

	## return indicator
	x
}

#' @usage NULL
#' @aliases concealing_baby_swallow
#'
#' @export
concealing_baby_swallow.data.frame <- function(
	x,
	cols,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases concealing_baby_swallow
#'
#' @export
concealing_baby_swallow.matrix <- function(
	x,
	cols,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases concealing_baby_swallow
#'
#' @export
concealing_baby_swallow.plotly <- function(
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
	constructed_indicator <- concealing_baby_swallow(
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
		pattern_name = "concealing_baby_swallow",
		agnostic = FALSE
	)

	plotly_object
}
