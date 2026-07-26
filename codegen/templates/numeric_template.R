#' @usage NULL
#' @aliases ${FUN}
#'
#' @export
${FUN}.numeric <- function(
	x,
	cols,
	${ARGS}
	na.bridge = FALSE,
	...) {

	## warn if 'cols' have been
	## passed just to make sure
	## the user knows its not possible
	## or relevant
	if (!missing(cols)) {
		warning("'cols' is passed but is unused for vectors.")
	}

	## pass the argument directly
	## to 'C'
	x <- .Call(
		C_impl_ta_${ALIAS},
		${C_NUMERIC},
		as.logical(na.bridge)
	)

	if (dim(x)[2] == 1L) {
		dim(x) <- NULL
	}

	x
}
