#' @export
#' @family Cycle Indicator
#'
#' @title Hilbert Transform - Phasor Components
#'
#' @templateVar .title Hilbert Transform - Phasor Components
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun ht_phasor
#'
#' @template description
ht_phasor <- function(
	x,
	cols,
	...
) {
	UseMethod("ht_phasor")
}

#' @export
#'
#' @usage NULL
#'
#' @rdname ht_phasor
#' @aliases ht_phasor
HT_PHASOR <- ht_phasor

#' @usage NULL
#' @aliases ht_phasor
#' @export
ht_phasor.default <- function(
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
			"impl_ta_HT_PHASOR",
			x[[1]]
		)
	)

	return(x)
}


#' @usage NULL
#' @aliases ht_phasor
#' @export
ht_phasor.data.frame <- function(
	x,
	cols,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases ht_phasor
#' @export
ht_phasor.numeric <- function(
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
		"impl_ta_HT_PHASOR",
		x
	)
}

#' @usage NULL
#' @aliases ht_phasor
#' @export
ht_phasor.matrix <- function(
	x,
	cols,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases ht_phasor
#' @export
ht_phasor.plotly <- function(
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
	.indicator <- ht_phasor.default(
		x = x,
		cols = cols
	)

	.indicator$idx <- 1:nrow(.indicator)

	output <- plotly::plot_ly(
		data = .indicator,
		name = "Phasor Components",
		x = ~idx,
		y = ~inphase
	)

	output <- plotly::add_lines(
		output,
		x = ~idx,
		y = ~quadrature,
		data = .indicator,
		inherit = FALSE
	)

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(output)
	)

	output
}
