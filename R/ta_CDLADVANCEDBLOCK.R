#' @export
#' @family Pattern Recognition
#'
#' @title Advance Block
#'
#' @templateVar .title Advance Block
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun advance_block
#'
#' @template description
#'
#' @returns
#' \describe{
#'  \item{advance_block}{1 for bullish, -1 for bearish and 0 for no pattern}
#' }
advance_block <- function(
	x,
	cols,
	...
) {
	UseMethod(
		"advance_block"
	)
}

#' @usage NULL
#' @aliases advance_block
#' @export
CDLADVANCEBLOCK <- advance_block

#' @usage NULL
#' @aliases advance_block
#' @export
advance_block.default <- function(
	x,
	cols,
	...
) {
	## validate input
	## asssuming everyting
	## is numerical values
	if (!missing(cols)) {
		## check if formula
		asset(
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

		## check if formula has the expected
		## length
		assert(
			length(all.vars(cols)) == 4,
			paste0(
				"'cols' has to be length 4. ",
				"Got length ",
				length(all.vars(cols))
			)
		)
	}

	## construct OHLC-series
	## from 'x'
	OHLC <- series(
		x = cols,
		default = ~ open + high + low + close,
		data = x,
		...
	)

	## construct data.frame
	## from source
	x <- as.data.frame(
		.Call(
			"impl_ta_CDLADVANCEBLOCK",
			x[[1]],
			x[[2]],
			x[[3]],
			x[[4]],
			as.logical(
				getOption("talib.normalize", TRUE)
			)
		)
	)

	## set column names
	colnames(x) <- "advance_block"

	## return value
	return(x)
}

#' @usage NULL
#' @aliases advance_block
#' @export
advance_block.data.frame <- function(
	x,
	cols,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases advance_block
#' @export
advance_block.matrix <- function(
	x,
	cols,
	...
) {
	as.matrix(
		NextMethod()
	)
}
