#' @export
#' @family Pattern Recognition
#'
#' @title Upside Gap Two Crows
#' @templateVar .title Upside Gap Two Crows
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun upside_gap_2_crows
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
upside_gap_2_crows <- function(
	x,
	cols,
	...
) {
	UseMethod("upside_gap_2_crows")
}

#' @export
#' @usage NULL
#' @rdname upside_gap_2_crows
#'
#' @aliases upside_gap_2_crows
CDLUPSIDEGAP2CROWS <- upside_gap_2_crows

#' @usage NULL
#' @aliases upside_gap_2_crows
#'
#' @export
upside_gap_2_crows.default <- function(
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
			"impl_ta_CDLUPSIDEGAP2CROWS",
			constructed_series[[1]],
			constructed_series[[2]],
			constructed_series[[3]],
			constructed_series[[4]],
			normalize
		)
	)

	## add column name
	colnames(x) <- "CDLUPSIDEGAP2CROWS"

	## readd rownames
	rownames(x) <- x_names

	## return indicator
	x
}

#' @usage NULL
#' @aliases upside_gap_2_crows
#'
#' @export
upside_gap_2_crows.data.frame <- function(
	x,
	cols,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases upside_gap_2_crows
#'
#' @export
upside_gap_2_crows.matrix <- function(
	x,
	cols,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases upside_gap_2_crows
#'
#' @export
upside_gap_2_crows.plotly <- function(
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
	constructed_indicator <- upside_gap_2_crows(
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
		pattern_name = "upside_gap_2_crows",
		agnostic = FALSE
	)

	plotly_object
}
