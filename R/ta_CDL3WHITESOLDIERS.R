#' @export
#' @family Pattern Recognition
#'
#' @title Three White Soldiers
#' @templateVar .title Three White Soldiers
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun three_white_soldiers
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
three_white_soldiers <- function(
	x,
	cols,
	...
) {
	UseMethod("three_white_soldiers")
}

#' @export
#' @usage NULL
#' @rdname three_white_soldiers
#'
#' @aliases three_white_soldiers
CDL3WHITESOLDIERS <- three_white_soldiers

#' @usage NULL
#' @aliases three_white_soldiers
#'
#' @export
three_white_soldiers.default <- function(
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
			"impl_ta_CDL3WHITESOLDIERS",
			constructed_series[[1]],
			constructed_series[[2]],
			constructed_series[[3]],
			constructed_series[[4]],
			normalize
		)
	)

	## add column name
	colnames(x) <- "CDL3WHITESOLDIERS"

	## readd rownames
	rownames(x) <- x_names

	## return indicator
	x
}

#' @usage NULL
#' @aliases three_white_soldiers
#'
#' @export
three_white_soldiers.data.frame <- function(
	x,
	cols,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases three_white_soldiers
#'
#' @export
three_white_soldiers.matrix <- function(
	x,
	cols,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases three_white_soldiers
#'
#' @export
three_white_soldiers.plotly <- function(
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
	constructed_indicator <- three_white_soldiers(
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
		pattern_name = "three_white_soldiers",
		agnostic = FALSE
	)

	plotly_object
}
