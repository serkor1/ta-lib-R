#' @export
#' @family Momentum Indicator
#'
#' @title Absolute Price Oscillator
#' @templateVar .title Absolute Price Oscillator
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun absolute_price_oscillator
#' @templateVar .family Momentum Indicator
#' @templateVar .formula ~close
#'
## splice:documentation:start
#' @param fast ([integer]). Period for the fast Moving Average (MA).
#' @param slow ([integer]). Period for the slow Moving Average (MA).
#' @param ma ([list]). The type of Moving Average (MA) used for the `fast` and `slow` MA. [SMA] by default.
## splice:documentation:end
#'
#' @template description
#' @template returns
absolute_price_oscillator <- function(
	x,
	cols,
	fast = 7,
	slow = 14,
	ma = SMA(n = 10),
	...
) {
	UseMethod("absolute_price_oscillator")
}

#' @export
#' @usage NULL
#' @rdname absolute_price_oscillator
#'
#' @aliases absolute_price_oscillator
APO <- absolute_price_oscillator

#' @usage NULL
#' @aliases absolute_price_oscillator
#'
#' @export
absolute_price_oscillator.default <- function(
	x,
	cols,
	fast = 7,
	slow = 14,
	ma = SMA(n = 10),
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
		"impl_ta_APO",
		## splice:call:start
		constructed_series[[1]],
		as.integer(fast),
		as.integer(slow),
		ma$maType
		## splice:call:end
	)

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases absolute_price_oscillator
#'
#' @export
absolute_price_oscillator.data.frame <- function(
	x,
	cols,
	fast = 7,
	slow = 14,
	ma = SMA(n = 10),
	...
) {
	as.data.frame(
		absolute_price_oscillator.default(
			x = x,
			cols = cols,
			fast = fast,
			slow = slow,
			ma = ma,
			...
		)
	)
}

#' @usage NULL
#' @aliases absolute_price_oscillator
#'
#' @export
absolute_price_oscillator.matrix <- function(
	x,
	cols,
	fast = 7,
	slow = 14,
	ma = SMA(n = 10),
	...
) {
	as.matrix(
		absolute_price_oscillator.default(
			x = x,
			cols = cols,
			fast = fast,
			slow = slow,
			ma = ma,
			...
		)
	)
}

#' @usage NULL
#' @aliases absolute_price_oscillator
#'
#' @export
absolute_price_oscillator.numeric <- function(
	x,
	cols,
	fast = 7,
	slow = 14,
	ma = SMA(n = 10),
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
		"impl_ta_APO",
		## splice:numeric:start
		as.double(x),
		as.integer(fast),
		as.integer(slow),
		ma$maType
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
#' @aliases absolute_price_oscillator
#'
#' @export
absolute_price_oscillator.plotly <- function(
	x,
	cols,
	fast = 7,
	slow = 14,
	ma = SMA(n = 10),
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
	constructed_indicator <- absolute_price_oscillator(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		fast = fast,
		slow = slow,
		ma = ma
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {plotly}-object
	## splice:plotly-assembly:start
	plotly_object <- subchart(
		data = constructed_indicator,
		y = ~APO,
		type = "scatter",
		mode = "lines",
		showlegend = FALSE
	)

	plotly_object <- plotly::add_lines(
		plotly_object,
		x = constructed_indicator$idx,
		y = rep(0, nrow(constructed_indicator)),
		inherit = FALSE,
		showlegend = FALSE,
		line = list(
			color = "lightgray",
			dash = "dash"
		)
	)

	if (main_chart_exists()) {
		plotly_object <- add_title(
			x = plotly_object,
			text = sprintf(
				"Absolute Price Oscillator (%d, %d)",
				fast,
				slow
			)
		)
	}

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(plotly_object)
	)
	## splice:plotly-assembly:end

	plotly_object
}
