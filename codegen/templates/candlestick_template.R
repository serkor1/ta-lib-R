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
#' @returns
#' An object of same [class] and [length] of `x`:
#'
#' \describe{
#'  \item{${ALIAS}}{[integer]}
#' }
#'
#' Pattern codes depend on `options(talib.normalize)`:
#'
#' * If `TRUE`: `1` = identified pattern; `-1` = identified bearish pattern.
#' * If `FALSE`: `100` = identified pattern; `-100` = identified bearish pattern.
#' * `0` = no pattern.
#'
#' @template description
#' @template candlestick
${FUN} <- function(
	x,
	cols,
	${ARGS}
	na.bridge = FALSE,
	...) {
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

	## get candlestick pattern
	## options
	##
	## NOTE: this adds an overhead
	##       of ~60% (from 50 microseconds to 80 microseconds) it needs to be set outside of the function without bloating the number of functions
	candlestick_setting()

	## get normalization option
	normalize <- as.logical(
		getOption("talib.normalize", TRUE)
	)

	## validate 'cols'-argument
	## if explicitly passed
	if (!missing(cols)) {
		assert_formula(cols)
	}

	## construct series
	## from input
	constructed_series <- series(
		x = x,
		formula.default = ${FORMULA},
		formula = cols,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- index(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
			C_impl_ta_${ALIAS},
			${C_SIGNATURE},
			normalize,
			as.logical(na.bridge)
		)

	## add column name
	colnames(x) <- "${ALIAS}"

	## readd rownames
	set_index(x, x_names)

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
	as.data.frame(
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
		as.matrix(
${FUN}.default(
			x = x,
			cols = cols ,
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
${FUN}.xts <- function(
	x,
	cols,
	${ARGS}
	na.bridge = FALSE,
	...) {

		as.xts(
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
${ALIAS}_lookback <- ${CAMEL_LOOKBACK}${FUN}_lookback <- function(
	x,
	cols,${ARGS}
	na.bridge = FALSE,
	...
) {
	.Call(
		C_impl_ta_${ALIAS}_lookback${C_SIGNATURE_LOOKBACK}
	)
}
