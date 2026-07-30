#' @export
#' @family ${FAMILY}
#'
#' @title ${TITLE}
#' @templateVar .title ${TITLE}
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun ${FUN}
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template rolling_description
${PARAM_DOCS}
#' @template rolling_returns
${FUN} <- function(
	${SERIES}
	${ARGS}
	na.bridge = FALSE, ...) {
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
	${SERIES}
	${ARGS}
	na.bridge = FALSE, ...) {

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		C_impl_ta_${ALIAS},
		## splice:call:start
		${C_NUMERIC},,,
		## splice:call:end
		as.logical(na.bridge)
	)

	## strip dimensions
	## while preserving
	## attributes
	dim(x) <- NULL

	## return indicator
	x
}

#' @usage NULL
#' @aliases ${FUN}
#'
#' @export
${FUN}.numeric <- function(
	${SERIES}
	${ARGS}
	na.bridge = FALSE, ...) {

	## calculate indicator and
	## return as data.frame
	x <- ${FUN}.default(
		${PSERIES}
		${PARGS}
		na.bridge = na.bridge
	)

	## strip dimensions
	## while preserving
	## attributes
	dim(x) <- NULL

	## return indicator
	x
}

#' @usage NULL
${ALIAS}_lookback <- ${CAMEL_LOOKBACK}${FUN}_lookback <- function(
	x,${ARGS}
	na.bridge = FALSE,
	...
) {
	.Call(
		C_impl_ta_${ALIAS}_lookback${C_SIGNATURE_LOOKBACK}
	)
	
}