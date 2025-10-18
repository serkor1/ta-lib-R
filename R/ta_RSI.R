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
				length(all.vars(cols)),
				paste(all.vars(cols), collapse = " and ")
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
	color = "lightgray",
	alpha = 0.2,
	...
) {
	## prepare univariate series
	## for RSI
	x <- as.data.frame(
		series(
			x = x,
			formula = cols,
			default = ~open,
			...
		)
	)

	## calculate indicator
	## and return as data.frame
	.indicator <- relative_strength_index.default(
		x = x,
		## pass the column
		## based on 'x'
		cols = rebuild_formula(
			names(x)
		),
		n = n
	)

	## add x-axis conditional on whether
	## the data have been subsetted or not
	.indicator$idx <- add_idx(
		x
	)

	## generate plotly object
	## of the indicator
	plotly_object <- subchart(
		data = .indicator,
		y = ~RSI,
		type = "scatter",
		mode = "lines",
		showlegend = FALSE
	)

	plotly_object <- plotly::add_ribbons(
		plotly_object,
		x = ~idx,
		ymin = rep(lower_band, nrow(.indicator)),
		ymax = rep(upper_band, nrow(.indicator)),
		line = list(width = 0),
		fillcolor = plotly::toRGB(
			x = color,
			alpha = alpha
		)
	)

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(plotly_object)
	)

	plotly_object
}
