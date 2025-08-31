#' @export
#' @family Overlap Study
#' @title Triple Exponential Moving Average (TEMA)
#'
#' @templateVar .title Triple Exponential Moving Average (TEMA)
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun TEMA
#'
#' @template description
TEMA <- function(
	x,
	cols,
	n = 10,
	...
) {
	UseMethod("TEMA")
}

#' @rdname TEMA
#' @usage NULL
#' @export
triple_exponential_moving_average <- TEMA

#' @rdname TEMA
#' @usage NULL
#' @export
TEMA.default <- function(
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
				4L
			)
		},
		FUN.VALUE = double(nrow(x)),
		USE.NAMES = TRUE
	)

	colnames(x) <- paste0("tema_", colnames(x))

	x
}

#' @rdname TEMA
#' @usage NULL
#' @export
TEMA.numeric <- function(
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
		"impl_ta_MA",
		as.double(x),
		as.integer(n),
		4L
	)
}


#' @rdname TEMA
#' @usage NULL
#' @export
TEMA.data.frame <- function(
	x,
	n = 10,
	cols,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @rdname TEMA
#' @usage NULL
#' @export
TEMA.matrix <- function(
	x,
	n = 10,
	cols,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @rdname TEMA
#' @usage NULL
#' @export
TEMA.plotly <- function(
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
				name = sprintf("TEMA(%d)", n),
				inherit = FALSE
			)
		})
	}

	.plotting_environment$main
}
