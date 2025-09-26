#' @export
#' @family Momentum Indicator
#'
#' @title Relative Strength Index
#'
#' @templateVar .title Relative Strength Index
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun relative_strength_index
#'
#' @template description
relative_strength_index <- function(
	x,
	cols,
	n = 10,
	...
) {
	UseMethod(
		"relative_strength_index"
	)
}

#' @export
#'
#' @usage NULL
#'
#' @rdname relative_strength_index
#' @aliases relative_strength_index
RSI <- relative_strength_index

#' @usage NULL
#' @aliases relative_strength_index
#' @export
relative_strength_index.default <- function(
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
			length(all.vars(cols)) == 1,
			paste0(
				"'cols' has to be length 1. ",
				"Got length ",
				length(all.vars(cols))
			)
		)
	}

	x <- series(
		x = cols,
		default = ~open,
		data = x,
		...
	)

	## 1) pass `x` to C
	data.frame(
		RSI = .Call(
			"impl_ta_RSI",
			x[[1]],
			as.integer(n)
		)
	)
}

#' @usage NULL
#' @aliases relative_strength_index
#' @export
relative_strength_index.numeric <- function(
	x,
	cols,
	n = 10,
	...
) {
	if (!missing(cols)) {
		warning(
			"'cols' have been passed but is unused in for vectors"
		)
	}

	.Call(
		"impl_ta_RSI",
		as.double(x),
		as.integer(n)
	)
}

#' @usage NULL
#' @aliases relative_strength_index
#' @export
relative_strength_index.data.frame <- function(
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
#' @aliases relative_strength_index
#' @export
relative_strength_index.matrix <- function(
	x,
	cols,
	n = 10,
	...
) {
	## NOTE: NextMethod dispactes
	## 		 to numeric
	as.matrix(
		relative_strength_index.default(
			x = x,
			cols = cols,
			n = n,
			...
		)
	)
}

#' @usage NULL
#' @aliases relative_strength_index
#' @export
relative_strength_index.plotly <- function(
	x,
	cols,
	n = 10,
	lower_band = 20,
	upper_band = 80,
	...
) {
	## prepare series
	## from
	x <- as.data.frame(
		series(
			x = x,
			formula = cols,
			default = ~open,
			...
		)
	)

	## indicator
	.indicator <- as.data.frame(NextMethod())
	.indicator$idx <- 1:nrow(.indicator)

	rsi_plot <- plotly::plot_ly(
		.indicator,
		x = ~idx,
		y = ~RSI,
		type = "scatter",
		mode = "lines",
		showlegend = FALSE
	)
	rsi_plot <- plotly::add_ribbons(
		rsi_plot,
		x = ~idx,
		ymin = rep(lower_band, nrow(.indicator)),
		ymax = rep(upper_band, nrow(.indicator)),
		line = list(width = 0),
		fillcolor = "rgba(160,160,160,0.20)"
	)

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(rsi_plot)
	)

	rsi_plot
}
