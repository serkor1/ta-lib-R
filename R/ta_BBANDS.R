#' @export
#' @family Overlap Study
#'
#' @title Bollinger Bands
#'
#' @templateVar .title Bollinger Bands
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun bollinger_bands
#'
#' @param ma A function call to a moving average function.
#' @param up,down A pair of [double] for upper and lower standard deviations.
#'
#' @returns
#' A [data.frame]- or [matrix]-object with the format:
#'
#' \describe{
#'  \item{upper}{[double]. The lower band.}
#'  \item{middle}{[double]. The middle band.}
#'  \item{lower}{[double]. The upper band.}
#' }
#'
#' @template description
bollinger_bands <- function(
	x,
	cols,
	ma = SMA(n = 10),
	up = 2,
	down = 2,
	...
) {
	UseMethod(
		generic = "bollinger_bands"
	)
}

#' @usage NULL
#' @aliases bollinger_bands
#' @export
BBANDS <- bollinger_bands

#' @usage NULL
#' @aliases bollinger_bands
#' @export
bollinger_bands.default <- function(
	x,
	cols,
	ma = SMA(n = 10),
	up = 2,
	down = 2,
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
	ma <- map_maType_call(substitute(ma))

	x <- series(
		x = cols,
		default = ~open,
		data = x,
		...
	)

	## 1) pass `x` assuming that it
	##    follows OHLC-V structure
	as.data.frame(
		.Call(
			"impl_ta_BBANDS",
			as.double(x[[1]]),
			ma$n,
			as.numeric(up),
			as.numeric(down),
			as.integer(ma$maType)
		)
	)
}

#' @usage NULL
#' @aliases bollinger_bands
#' @export
bollinger_bands.numeric <- function(
	x,
	cols,
	ma = SMA(n = 10),
	up = 2,
	down = 2,
	...
) {
	ma <- map_maType_call(substitute(ma))

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

	as.data.frame(
		.Call(
			"impl_ta_BBANDS",
			as.double(x),
			ma$n,
			as.numeric(up),
			as.numeric(down),
			as.integer(ma$maType)
		)
	)
}

#' @usage NULL
#' @aliases bollinger_bands
#' @export
bollinger_bands.data.frame <- function(
	x,
	cols,
	ma = SMA(n = 10),
	up = 2,
	down = 2,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases bollinger_bands
#' @export
bollinger_bands.matrix <- function(
	x,
	cols,
	ma = SMA(n = 10),
	up = 2,
	down = 2,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases bollinger_bands
#' @export
bollinger_bands.plotly <- function(
	x,
	cols,
	ma = SMA(n = 10),
	up = 2,
	down = 2,
	...
) {
	ma <- map_maType_call(substitute(ma))

	## prepare series
	## from
	x <- series(
		x = x,
		formula = cols,
		default = ~open,
		...
	)

	.indicator <- as.data.frame(
		.Call(
			"impl_ta_BBANDS",
			as.double(x[[1]]),
			ma$n,
			as.numeric(up),
			as.numeric(down),
			as.integer(ma$maType)
		)
	)

	.indicator$idx <- 1:nrow(.indicator)

	## constuct chart
	## element
	for (i in seq_len(ncol(.indicator) - 1)) {
		local({
			j <- i

			.plotting_environment$main <- plotly::add_lines(
				.plotting_environment$main,
				data = .indicator,
				x = ~idx,
				y = ~ .indicator[, j],
				inherit = FALSE,
				line = list(
					color = '#4682b4'
				),
				showlegend = FALSE,
				legendgroup = 'bollinger_band',
				name = c(
					"Upper Band",
					"Middle Band",
					"Lower Band"
				)[j],
			)
		})
	}

	.plotting_environment$main <- plotly::add_ribbons(
		p = .plotting_environment$main,
		inherit = FALSE,
		data = .indicator,
		x = ~idx,
		ymin = ~ .indicator[, 3],
		ymax = ~ .indicator[, 1],
		fillcolor = plotly::toRGB("#4682b4", alpha = 0.2),
		line = list(
			color = "transparent"
		),
		showlegend = TRUE,
		legendgroup = 'bollinger_band',
		name = paste0(
			"BBand"
		)
	)

	.plotting_environment$main
}
