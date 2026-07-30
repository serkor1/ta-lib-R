#' @export
#' @family ${FAMILY}
#'
#' @title ${TITLE}
#' @templateVar .title ${TITLE}
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun ${FUN}
#' @templateVar .family ${FAMILY}
#' @templateVar .formula ${FORMULA}
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @details
#' When passed without 'x', [${FUN}] functions as an 'Moving Average'-specification which is used in, for example, [stochastic] when constructing the smoothing lines.
#'
#' When called without 'x' it will return a named list which is used for the
#' indicators that supports various Moving Average specifications.
#'
#' @template description
${PARAM_DOCS}
#' @template returns
${FUN} <- function(
	x,
	cols,
	${ARGS}
	na.bridge = FALSE,
	...) {

	## if 'x' is missing ${FUN} functions
	## as a Moving Average Specification
	if (missing(x)) {
		## construct Moving Average specification
		## from call
		x <- structure(
			list(
				${SPEC_FIELDS},
				maType = ${MA_TYPE}
			),
			class = "maType"
		)

		return(x)
	}

	UseMethod("${FUN}")
}

#' @export
#' @usage NULL
#' @rdname ${FUN}
#'
#' @aliases ${FUN}
${ALIAS} <- ${FUN}
#camel#
#camel##' @export
#camel##' @usage NULL
#camel##' @rdname ${FUN}
#camel##'
#camel##' @aliases ${FUN}
#camel#${CAMEL} <- ${FUN}

#' @usage NULL
#' @aliases ${FUN}
#'
#' @export
${FUN}.default <- function(
	x,
	cols,
	${ARGS}
	na.bridge = FALSE,
	...) {

	## validate 'cols'-argument
	## if explicitly passed
	if (!missing(cols)) {
		assert_formula(cols)
	}

	## construct series
	## from input
	constructed_series <- series(
		x = cols,
		default_formula = ${FORMULA},
		data = x,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- rownames(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		C_impl_ta_${ALIAS},
		${C_SIGNATURE},
		as.logical(na.bridge)
	)

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases ${FUN}
#'
#' @export
${FUN}.data.frame <- function(
	x,
	cols,
	${ARGS}
	na.bridge = FALSE,
	...
) {
	map_dfr(
		${FUN}.default(
			x = x,
			cols = cols,
			${PARGS}
			na.bridge = na.bridge,
			...
		)
	)

}

#' @usage NULL
#' @aliases ${FUN}
#'
#' @export
${FUN}.matrix <- function(
	x,
	cols,
	${ARGS}
	na.bridge = FALSE,
	...) {

	${FUN}.default(
			x = x,
			cols = cols ,
			${PARGS}
			na.bridge = na.bridge,
			...
		)
}

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

	## pass to 'C' directly
	## with the input vector
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

#' @usage NULL
${ALIAS}_lookback <- ${CAMEL_LOOKBACK}${FUN}_lookback <- function(
	x,
	cols,
	${ARGS}
	na.bridge = FALSE,
	...
) {

	.Call(
		C_impl_ta_${ALIAS}_lookback${C_SIGNATURE_LOOKBACK}
	)
}

