#' @export
#' @family Cycle Indicator
#'
#' @title Hilbert Transform - Dominant Cycle Phase
#'
#' @templateVar .title Hilbert Transform - Dominant Cycle Phase
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun ht_dc_phase
#'
#' @template description
ht_dc_phase <- function(
	x,
	cols,
	...
) {
	UseMethod("ht_dc_phase")
}

#' @export
#'
#' @usage NULL
#'
#' @rdname ht_dc_phase
#' @aliases ht_dc_phase
HT_DCPHASE <- ht_dc_phase

#' @usage NULL
#' @aliases ht_dc_phase
#' @export
ht_dc_phase.default <- function(
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
			"impl_ta_HT_DCPHASE",
			x[[1]]
		)
	)

	colnames(x)[1] <- "dominant_cycle_phase"

	return(x)
}


#' @usage NULL
#' @aliases ht_dc_phase
#' @export
ht_dc_phase.data.frame <- function(
	x,
	cols,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases ht_dc_phase
#' @export
ht_dc_phase.numeric <- function(
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
		"impl_ta_HT_DCPHASE",
		x
	)
}

#' @usage NULL
#' @aliases ht_dc_phase
#' @export
ht_dc_phase.matrix <- function(
	x,
	cols,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases ht_dc_phase
#' @export
ht_dc_phase.plotly <- function(
	x,
	cols,
	...
) {
	## prepare univariate
	## series for DC phase
	x <- as.data.frame(
		series(
			x = x,
			formula = cols,
			default = ~open,
			...
		)
	)

	## construct DC phase
	## as data.frame
	.indicator <- ht_dc_phase.default(
		x = x,
		cols = rebuild_formula(
			names(x)
		)
	)

	## add x-axis conditional on whether
	## the data have been subsetted or not
	.indicator$idx <- add_idx(
		x
	)

	## construct indicator
	## as plotly object
	plotly_object <- subchart(
		data = .indicator,
		y = ~dominant_cycle_phase,
		type = "scatter",
		mode = "markers",
		name = "DC Phase"
	)

	if (main_chart_exists()) {
		plotly_object <- add_title(
			x = plotly_object,
			text = "Dominant Cycle Phase"
		)
	}

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(plotly_object)
	)

	plotly_object
}
