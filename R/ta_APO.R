#' @export
#' @family Momentum Indicator
#'
#' @title Absolute Price Oscillator
#' @templateVar .title Absolute Price Oscillator
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun absolute_price_oscillator
#'
#'
## input start
#' @param fast something
#' @param slow something
#' @param ma something
## input end
#'
#' @template description
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

	## extract rownames
	## for later attachment
	x_names <- rownames(x)

	## construct series
	## from input
	constructed_series <- series(
		x = cols,
		default = ~close,
		data = x,
		...
	)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		"impl_ta_APO",
		## input start
		constructed_series[[1]],
		as.integer(fast),
		as.integer(slow),
		ma$maType
		## input end
	)

	## readd rownames
	rownames(x) <- x_names

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
		NextMethod()
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
		NextMethod()
	)
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
		fast = 7,
		slow = 14,
		ma = SMA(n = 10)
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {plotly}-object
	## input start
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
	## input end

	plotly_object
}
