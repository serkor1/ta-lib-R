#' @export
#' @family Cycle Indicator
#'
#' @title Hilbert Transform - Dominant Cycle Period
#'
#' @templateVar .title Hilbert Transform - Dominant Cycle Period
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun ht_dcperiod
#'
#' @template description
ht_dcperiod <- function(
	x,
	cols,
	...
) {
	UseMethod("ht_dcperiod")
}

#' @usage NULL
#' @aliases ht_dcperiod
#' @export
HT_DCPERIOD <- ht_dcperiod

#' @usage NULL
#' @aliases ht_dcperiod
#' @export
ht_dcperiod.default <- function(
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
			"impl_ta_HT_DCPERIOD",
			x[[1]]
		)
	)

	colnames(x)[1] <- "dominant_cycle_period"

	return(x)
}


#' @usage NULL
#' @aliases ht_dcperiod
#' @export
ht_dcperiod.data.frame <- function(
	x,
	cols,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases ht_dcperiod
#' @export
ht_dcperiod.numeric <- function(
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
		"impl_ta_HT_DCPERIOD",
		x
	)
}

#' @usage NULL
#' @aliases ht_dcperiod
#' @export
ht_dcperiod.matrix <- function(
	x,
	cols,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases ht_dcperiod
#' @export
ht_dcperiod.plotly <- function(
	x,
	cols,
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

	## construct indicator
	##
	.indicator <- ht_dcperiod.default(
		x = x,
		cols = cols
	)

	.indicator$idx <- 1:nrow(.indicator)

	output <- plotly::plot_ly(
		data = .indicator,
		name = "Dominant Cycle Period",
		x = ~idx,
		y = ~dominant_cycle_period
	)

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(output)
	)

	output
}
