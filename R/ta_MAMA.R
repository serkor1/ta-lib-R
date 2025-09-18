#' @export
#' @family Overlap Study
#' @title Mesa Adaptive Moving Average (MAMA)
#'
#' @templateVar .title Mesa Adaptive Moving Average (MAMA)
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun MAMA
#'
#' @template description
MAMA <- function(
	x,
	cols,
	n = 10,
	...
) {
	UseMethod("MAMA")
}

#' @rdname MAMA
#' @usage NULL
#' @export
MAMA.default <- function(
	x,
	cols,
	n = 10,
	...
) {
	## default behaviour is to
	## check if its a numeric vector
	##
	## No coercing here as it might
	## lead to overflow
	x <- series(
		x = cols,
		default = ~open,
		data = x,
		...
	)

	## 0) validate input
	##    and stop the script
	##    if conditions are not
	##    met
	x <- vapply(
		as.list(x),
		FUN = function(x) {
			.Call(
				"impl_ta_MA",
				x,
				as.integer(n),
				7L
			)
		},
		FUN.VALUE = double(nrow(x)),
		USE.NAMES = TRUE
	)

	colnames(x) <- paste0("mama_", colnames(x))

	x
}

#' @rdname MAMA
#' @usage NULL
#' @export
MAMA.numeric <- function(
	x,
	cols,
	n = 10,
	...
) {
	if (!is.missing(cols)) {
		warning(
			"'cols' have been passed but is unused in for vectors"
		)
	}

	.Call(
		"impl_ta_MA",
		as.double(x),
		as.integer(n),
		7L
	)
}


#' @rdname MAMA
#' @usage NULL
#' @export
MAMA.data.frame <- function(
	x,
	cols,
	n = 10,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @rdname MAMA
#' @usage NULL
#' @export
MAMA.matrix <- function(
	x,
	cols,
	n = 10,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @rdname MAMA
#' @usage NULL
#' @export
MAMA.plotly <- function(
	x,
	cols,
	n = 10,
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

	for (i in 1:ncol(x)) {
		local({
			j <- i
			.plotting_environment$main <- plotly::add_trace(
				.plotting_environment$main,
				data = .indicator,
				x = ~idx,
				y = ~ .indicator[, j],
				type = "scatter",
				mode = "lines",
				name = sprintf("MAMA(%d)", n),
				inherit = FALSE
			)
		})
	}

	.plotting_environment$main
}
