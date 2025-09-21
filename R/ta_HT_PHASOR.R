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
	...
) {
	UseMethod("ht_phasor")
}

#' @usage NULL
#' @aliases ht_phasor
#' @export
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

	colnames(x)[1] <- "dominant_cycle_period"

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
