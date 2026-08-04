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
#' @template description
${PARAM_DOCS}
#' @template returns
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

	## validate 'cols'-argument
	## if explicitly passed
	if (!missing(cols)) {
		assert_formula(cols)
	}

	## construct series
	## from input
	constructed_series <- series(
		x = x,
		formula = cols,
		formula.default = ${FORMULA},
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
		as.logical(na.bridge)
	)

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

		assert_xts()

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
	cols,
	${ARGS}
	na.bridge = FALSE,
	...
) {

	.Call(
		C_impl_ta_${ALIAS}_lookback${C_SIGNATURE_LOOKBACK}
	)

}
