#' @export
#' @family Cycle Indicator
#'
#' @title Hilbert Transform - SineWave
#'
#' @templateVar .title Hilbert Transform - SineWave
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun ht_sine_wave
#'
#' @template description
ht_sine_wave <- function(
	x,
	...
) {
	UseMethod("ht_sine_wave")
}

#' @usage NULL
#' @aliases ht_sine_wave
#' @export
HT_SINE <- ht_sine_wave

#' @usage NULL
#' @aliases ht_sine_wave
#' @export
ht_sine_wave.default <- function(
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
			"impl_ta_HT_SINE",
			x[[1]]
		)
	)

	colnames(x)[1] <- "dominant_cycle_period"

	return(x)
}


#' @usage NULL
#' @aliases ht_sine_wave
#' @export
ht_sine_wave.data.frame <- function(
	x,
	cols,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases ht_sine_wave
#' @export
ht_sine_wave.numeric <- function(
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
		"impl_ta_HT_SINE",
		x
	)
}

#' @usage NULL
#' @aliases ht_sine_wave
#' @export
ht_sine_wave.matrix <- function(
	x,
	cols,
	...
) {
	as.matrix(
		NextMethod()
	)
}
