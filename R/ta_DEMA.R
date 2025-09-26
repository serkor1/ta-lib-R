#' @export
#' @family Overlap Study
#' @title Double Exponential Moving Average (DEMA)
#'
#' @templateVar .title Double Exponential Moving Average (DEMA)
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun DEMA
#'
#' @template description
DEMA <- function(
	x,
	cols,
	n = 10,
	...
) {
	## if 'x' is missing
	## its safe to assume that
	## the user is calling via
	## indicator()
	if (missing(x)) {
		## construct the
		## call
		call <- match.call(expand.dots = FALSE)
		call$n <- n

		## construct ma specification
		## class
		x <- structure(
			{
				map_maType_call(
					call
				)
			},
			class = c("ma_specification")
		)

		return(x)
	}

	UseMethod("DEMA")
}

#' @export
#'
#' @usage NULL
#'
#' @rdname DEMA
#' @aliases DEMA
double_exponential_moving_average <- DEMA

#' @rdname DEMA
#' @usage NULL
#' @export
DEMA.default <- function(
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
				3L
			)
		},
		FUN.VALUE = double(nrow(x)),
		USE.NAMES = TRUE
	)

	colnames(x) <- paste0("dema_", colnames(x))

	x
}

#' @rdname DEMA
#' @usage NULL
#' @export
DEMA.numeric <- function(
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
		3L
	)
}


#' @rdname DEMA
#' @usage NULL
#' @export
DEMA.data.frame <- function(
	x,
	cols,
	n = 10,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @rdname DEMA
#' @usage NULL
#' @export
DEMA.matrix <- function(
	x,
	cols,
	n = 10,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @rdname DEMA
#' @usage NULL
#' @export
DEMA.plotly <- function(
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
				name = sprintf("DEMA(%d)", n),
				inherit = FALSE
			)
		})
	}

	.plotting_environment$main
}
