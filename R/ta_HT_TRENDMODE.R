#' @export
#' @family Cycle Indicator
#'
#' @title Hilbert Transform - Trend vs Cycle Mode
#'
#' @templateVar .title Hilbert Transform - Trend vs Cycle Mode
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun ht_trendmode
#'
#' @template description
ht_trendmode <- function(
	x,
	cols,
	...
) {
	UseMethod("ht_trendmode")
}

#' @export
#'
#' @usage NULL
#'
#' @rdname ht_trendmode
#' @aliases ht_trendmode
HT_TRENDMODE <- ht_trendmode

#' @usage NULL
#' @aliases ht_trendmode
#' @export
ht_trendmode.default <- function(
	x,
	cols,
	...
) {
	if (!missing(cols)) {
		## check for formula
		assert(
			is.formula(cols),
			paste0(
				"'cols' has to be <",
				class(~s),
				">.",
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

	## extract series
	x <- series(
		x = cols,
		default = ~open,
		data = x,
		...
	)

	x <- as.data.frame(
		.Call(
			"impl_ta_HT_TRENDMODE",
			x[[1]]
		)
	)

	colnames(x)[1] <- "dominant_cycle_period"

	return(x)
}


#' @usage NULL
#' @aliases ht_trendmode
#' @export
ht_trendmode.data.frame <- function(
	x,
	cols,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases ht_trendmode
#' @export
ht_trendmode.numeric <- function(
	x,
	cols,
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
		"impl_ta_HT_TRENDMODE",
		x
	)
}

#' @usage NULL
#' @aliases ht_trendmode
#' @export
ht_trendmode.matrix <- function(
	x,
	cols,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @rdname ht_trendmode
#' @usage NULL
#' @export
ht_trendmode.plotly <- function(
	x,
	cols,
	...
) {
	## prepare univariate
	## series for the the
	## trendmode
	x <- as.data.frame(
		series(
			x = x,
			formula = cols,
			default = ~open,
			...
		)
	)

	## calculate the trendmode
	## and return as data.frame
	.indicator <- ht_trendmode.default(
		x = x,
		cols = rebuild_formula(
			names(x)
		)
	)

	## add idx based on the
	## univariate series
	.indicator$idx <- add_idx(
		x
	)

	plotly_object <- subchart(
		data = .indicator,
		y = ~dominant_cycle_period,
		type = "scatter",
		mode = "lines",
		name = "Trendmode",
		line = list(shape = "hvh")
	)

	if (main_chart_exists()) {
		plotly_object <- add_title(
			x = plotly_object,
			text = "Trendmode"
		)
	}

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(plotly_object)
	)

	plotly_object
}
