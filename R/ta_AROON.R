#' @export
#' @family Momentum Indicator
#'
#' @title Aroon
#' @templateVar .title Aroon
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun aroon
#'
#' @returns
#' A [data.frame]- or [matrix]-object:
#'
#' \describe{
#'  \item{aroon_up <[double]>}{}
#'  \item{aroon_down <[double]>}{}
#' }
#'
#' @template description
aroon <- function(
	x,
	cols,
	n = 10,
	...
) {
	UseMethod(
		generic = "aroon"
	)
}

#' @export
#'
#' @usage NULL
#'
#' @rdname aroon
#' @aliases aroon
AROON <- aroon

#' @export
aroon.default <- function(
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

	as.data.frame(
		.Call(
			"impl_ta_AROON",
			HL[[1]],
			HL[[2]],
			as.integer(n)
		)
	)
}


#' @usage NULL
#' @aliases aroon
#' @export
aroon.data.frame <- function(
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
#' @aliases aroon
#' @export
aroon.matrix <- function(
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
#' @aliases aroon
#' @export
aroon.plotly <- function(
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
	.indicator <- aroon.default(
		x = x,
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
		y = ~aroon_down,
		type = "scatter",
		mode = "lines",
		name = "AD",
		legendgroup = "Aroon",
		showlegend = FALSE
	)

	plotly_object <- plotly::add_lines(
		p = plotly_object,
		x = .indicator$idx,
		y = ~aroon_up,
		showlegend = FALSE,
		legendgroup = "Aroon"
	)

	if (main_chart_exists()) {
		plotly_object <- add_title(
			x = plotly_object,
			text = "Aroon"
		)
	}

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(plotly_object)
	)

	plotly_object
}
