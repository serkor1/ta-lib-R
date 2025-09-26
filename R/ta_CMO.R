#' @export
#' @family Momentum Indicator
#'
#' @title Chande Momentum Oscillator
#'
#' @templateVar .title Chande Momentum Oscillator
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun chande_momentum_oscillator
#'
#' @template description
chande_momentum_oscillator <- function(
	x,
	cols,
	n = 10,
	...
) {
	UseMethod(
		generic = "chande_momentum_oscillator"
	)
}

#' @export
#'
#' @usage NULL
#'
#' @rdname chande_momentum_oscillator
#' @aliases chande_momentum_oscillator
CMO <- chande_momentum_oscillator

#' @usage NULL
#' @aliases chande_momentum_oscillator
#' @export
chande_momentum_oscillator.default <- function(
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

	## default behaviour is to
	## coerce to a `matrix` check that
	## it is double and then pass to
	## C-side.
	x <- series(
		x = cols,
		default = ~open,
		data = x,
		...
	)

	## 1) pass `x` assuming that it
	##    follows OHLC-V structure
	x <- as.data.frame(
		.Call(
			"impl_ta_CMO",
			x[[1]],
			as.integer(n)
		)
	)

	colnames(x) <- "CMO"

	return(x)
}

#' @usage NULL
#' @aliases chande_momentum_oscillator
#' @export
chande_momentum_oscillator.numeric <- function(
	x,
	cols,
	n = 10,
	...
) {
	## determine branch
	## if its a matrix call
	## matrix method and end the function
	##
	## NOTE: this is necessary as matrix are
	##       internally doubles
	if (is.matrix(x)) {
		output <- NextMethod()

		return(output)
	}

	## treat 'x' as a vector
	##
	if (!missing(cols)) {
		warning(
			"'cols' have been passed but is unused in for vectors"
		)
	}

	.Call(
		"impl_ta_CMO",
		x,
		as.integer(n)
	)
}

#' @usage NULL
#' @aliases chande_momentum_oscillator
#' @export
chande_momentum_oscillator.data.frame <- function(
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
#' @aliases chande_momentum_oscillator
#' @export
chande_momentum_oscillator.matrix <- function(
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
#' @aliases chande_momentum_oscillator
#' @export
chande_momentum_oscillator.plotly <- function(
	x,
	cols,
	n = 10,
	...
) {
	## prepare series
	## from {plotly}-object
	x <- as.data.frame(
		series(
			x = x,
			formula = cols,
			default = ~open,
			...
		)
	)

	## construct indicator
	## NOTE: NextMethod might be risky
	##       here
	.indicator <- as.data.frame(
		.Call(
			"impl_ta_CMO",
			x[[1]],
			as.integer(n)
		)
	)

	colnames(.indicator) <- "CMO"

	.indicator$idx <- 1:nrow(.indicator)

	## construct plot with ribbons
	## on upper and lower limits
	output <- plotly::plot_ly(
		data = .indicator,
		x = ~idx,
		y = ~CMO,
		type = "scatter",
		mode = "lines",
		showlegend = FALSE
	)

	output <- plotly::add_ribbons(
		output,
		x = ~idx,
		ymin = rep(-50, nrow(.indicator)),
		ymax = rep(50, nrow(.indicator)),
		line = list(width = 0),
		fillcolor = plotly::toRGB(
			x = "lightgray",
			alpha = 0.2
		)
	)

	output <- add_title(
		x = output,
		text = sprintf(
			"Chande Momentum Indicator (%d)",
			n
		)
	)

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(output)
	)

	output
}
