#' @export
#' @family Overlap Study
#'
#' @title Hilbert Transform - Instantaneous Trendline
#' @templateVar .title Hilbert Transform - Instantaneous Trendline
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun trendline
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @template returns
trendline <- function(
	x,
	cols,
	...
) {
	UseMethod("trendline")
}

#' @export
#' @usage NULL
#' @rdname trendline
#'
#' @aliases trendline
HT_TRENDLINE <- trendline

#' @usage NULL
#' @aliases trendline
#'
#' @export
trendline.default <- function(
	x,
	cols,
	...
) {
	## validate 'cols'-argument
	## if explicitly passed
	if (!missing(cols)) {
		assert_formula(cols)
	}

	## construct series
	## from input
	constructed_series <- series(
		x = cols,
		default = ~close,
		data = x,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- rownames(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		"impl_ta_HT_TRENDLINE",
		## splice:call:start
		constructed_series[[1]]
		## splice:call:end
	)

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases trendline
#'
#' @export
trendline.data.frame <- function(
	x,
	cols,
	...
) {
	as.data.frame(
		trendline.default(
			x = x,
			cols = cols,
			...
		)
	)
}

#' @usage NULL
#' @aliases trendline
#'
#' @export
trendline.matrix <- function(
	x,
	cols,
	...
) {
	as.matrix(
		trendline.default(
			x = x,
			cols = cols,
			...
		)
	)
}

#' @usage NULL
#' @aliases trendline
#'
#' @export
trendline.numeric <- function(
	x,
	cols,
	...
) {
	## warn if 'cols' have been
	## passed just to make sure
	## the user knows its not possible
	## or relevant
	if (!missing(cols)) {
		warning("'cols' is passed but is unused for vectors.")
	}

	## pass the argument directly
	## to 'C'
	x <- .Call(
		"impl_ta_HT_TRENDLINE",
		as.double(x)
		## splice:numeric:start

		## splice:numeric:end
	)

	## check if it has 'dims'
	## and convert to double if
	## not to honor the 'type-safety'-esque
	## approach
	##
	## NOTE: this adds a few ns overhead but
	##       its a robust alternative to code it
	##       manually. Any suggestions are welcome
	if (is.null(dim(x))) {
		x <- as.double(x)
	}

	x
}

#' @usage NULL
#' @aliases trendline
#'
#' @export
trendline.plotly <- function(
	x,
	cols,
	## splice:optional-plotly:start
	## splice:optional-plotly:end
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
		default = ~close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- trendline(
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
	## splice:plotly-assembly:start
	plotly_object <- .plotting_environment[["main"]] <- plotly::add_trace(
		.plotting_environment[["main"]],
		data = constructed_indicator,
		x = ~idx,
		y = ~HT_TRENDLINE,
		type = "scatter",
		mode = "lines",
		name = "Trendline",
		inherit = FALSE
	)
	## splice:plotly-assembly:end

	plotly_object
}
