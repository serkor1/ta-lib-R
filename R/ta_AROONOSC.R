#' @export
#' @family Momentum Indicator
#'
#' @title Aroon Oscillator
#' @templateVar .title Aroon Oscillator
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun aroon_oscillator
#'
#' @returns
#' A [data.frame]- or [matrix]-object:
#'
#' \describe{
#'  \item{aroon_oscillator <[double]>}{}
#' }
#'
#' @template description
aroon_oscillator <- function(
	x,
	cols,
	n = 10,
	...
) {
	UseMethod(
		generic = "aroon_oscillator"
	)
}

#' @export
#'
#' @usage NULL
#'
#' @rdname aroon_oscillator
#' @aliases aroon_oscillator
AROONOSC <- aroon_oscillator

#' @export
aroon_oscillator.default <- function(
	x,
	cols,
	n = 10,
	...
) {
	## check input
	## cols if passed
	if (!missing(cols)) {
		assert(
			is.formula(cols),
			paste0(
				"'cols' has to be <",
				class(~s),
				">. ",
				"Got <",
				class(cols),
				">."
			)
		)
		assert(
			length(all.vars(cols)) == 2,
			paste0(
				"'cols' has to be length 2. ",
				"Got length ",
				length(all.vars(cols))
			)
		)
	}

	HL <- series(
		x = cols,
		default = ~ high + low,
		data = x,
		...
	)

	data.frame(
		aroon_oscillator = .Call(
			"impl_ta_AROONOSC",
			HL[[1]],
			HL[[2]],
			as.integer(n)
		)
	)
}


#' @usage NULL
#' @aliases aroon_oscillator
#' @export
aroon_oscillator.data.frame <- function(
	x,
	cols,
	n = 10,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases aroon_oscillator
#' @export
aroon_oscillator.matrix <- function(
	x,
	cols,
	n = 10,
	...
) {
	as.matrix(
		NextMethod()
	)
}


#' @usage NULL
#' @aliases aroon_oscillator
#' @export
aroon_oscillator.plotly <- function(
	x,
	cols,
	n = 10,
	...
) {
	## prepare HL series
	## for the aroon oscillator
	HL <- series(
		x = x,
		formula = cols,
		default = ~ high + low,
		...
	)

	## calculate indicator
	## and return as data.frame
	.indicator <- aroon_oscillator.default(
		x = HL,
		cols = rebuild_formula(
			names(HL)
		),
		n = n
	)

	## add x-axis conditional on whether
	## the data have been subsetted or not
	.indicator$idx <- add_idx(
		HL
	)

	## construct chart
	## element
	plotly_object <- subchart(
		data = .indicator,
		y = ~aroon_oscillator,
		type = "scatter",
		mode = "lines",
		name = sprintf(
			fmt = "AD(%d)",
			n
		),
		legendgroup = "Aroon",
		showlegend = FALSE
	)

	if (!is.null(.plotting_environment$main)) {
		plotly_object <- add_title(
			x = plotly_object,
			text = "Aroon Oscillator"
		)
	}

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(plotly_object)
	)

	plotly_object
}
