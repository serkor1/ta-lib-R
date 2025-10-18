#' @export
#' @family Overlap Study
#' @title T3 Moving Average (T3)
#'
#' @templateVar .title T3 Moving Average (T3)
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun T3
#'
#' @template description
T3 <- function(
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

	UseMethod("T3")
}

#' @export
#'
#' @usage NULL
#'
#' @rdname T3
#' @aliases T3
T3_moving_average <- T3

#' @rdname T3
#' @usage NULL
#' @export
T3.default <- function(
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
				8L
			)
		},
		FUN.VALUE = double(nrow(x)),
		USE.NAMES = TRUE
	)

	colnames(x) <- paste0("T3_", colnames(x))

	as.data.frame(x)
}

#' @rdname T3
#' @usage NULL
#' @export
T3.numeric <- function(
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
		8L
	)
}


#' @rdname T3
#' @usage NULL
#' @export
T3.data.frame <- function(
	x,
	cols,
	n = 10,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @rdname T3
#' @usage NULL
#' @export
T3.matrix <- function(
	x,
	cols,
	n = 10,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @rdname T3
#' @usage NULL
#' @export
T3.plotly <- function(
	x,
	cols,
	n = 10,
	...
) {
	## prepare univariate
	## series for T3
	x <- as.data.frame(
		series(
			x = x,
			formula = cols,
			default = ~open,
			...
		)
	)

	## calculator indicator
	## and return as data.frame
	.indicator <- T3.default(
		x = x,
		cols = rebuild_formula(
			x = names(x)
		),
		n = n
	)

	## add x-axis conditional on whether
	## the data have been subsetted or not
	.indicator$idx <- add_idx(
		x
	)

	for (i in 1:ncol(x)) {
		local({
			j <- i
			.plotting_environment$main <- plotly::add_trace(
				.plotting_environment$main,
				data = .indicator,
				x = ~idx,
				y = ~ .indicator[[j]],
				type = "scatter",
				mode = "lines",
				name = sprintf("T3(%d)", n),
				inherit = FALSE
			)
		})
	}

	.plotting_environment$main
}
