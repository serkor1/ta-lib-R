#' @export
#' @family Pattern Recognition
#'
#' @title Tristar
#' @templateVar .title Tristar
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun tristar
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
tristar <- function(
	x,
	cols,
	...
) {
	UseMethod("tristar")
}

#' @export
#' @usage NULL
#' @rdname tristar
#'
#' @aliases tristar
CDLTRISTAR <- tristar

#' @usage NULL
#' @aliases tristar
#'
#' @export
tristar.default <- function(
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
	x_names <- rownames(x)

	## calculate indicator and
	## return as data.frame
	x <- as.matrix(
		.Call(
			"impl_ta_CDLTRISTAR",
			constructed_series[[1]],
			constructed_series[[2]],
			constructed_series[[3]],
			constructed_series[[4]],
			normalize
		)
	)

	## add column name
	colnames(x) <- "CDLTRISTAR"

	## readd rownames
	rownames(x) <- x_names

	## return indicator
	x
}

#' @usage NULL
#' @aliases tristar
#'
#' @export
tristar.data.frame <- function(
	x,
	cols,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases tristar
#'
#' @export
tristar.matrix <- function(
	x,
	cols,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases tristar
#'
#' @export
tristar.plotly <- function(
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
	constructed_indicator <- tristar(
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
		pattern_name = "tristar",
		agnostic = FALSE
	)

	plotly_object
}
