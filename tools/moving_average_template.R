#' @export
#' @family $FAMILY
#'
#' @title $TITLE
#' @templateVar .title $TITLE
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun $FUN
#' 
#' @returns
#' A [data.frame]- or [matrix]-object:
#'
#' \describe{
#'  \item{$ALIAS <[double]>}{Values}
#' }
#'
#' @template description
$FUN <- function(
	x, 
	cols, 
	n = 10,
	...) {

		## if 'x' is missing $FUN functions
		## as a Moving Average Specification
		if (missing(x)) {
			## construct Moving Average specification
			## from call
			x <- structure(
				{
				list(
					n = if (missing(n)) 10L else as.integer(n),
					maType = as.integer($DEFAULT_FORMULA)
				)	
				}
			)

			return(x)
		}
  UseMethod("$FUN")
}

#' @export
#' @usage NULL
#' @rdname $FUN
#' 
#' @aliases $FUN
$ALIAS <- $FUN

#' @usage NULL
#' @aliases $FUN
#' 
#' @export
$FUN.default <- function(
	x, 
	cols, 
	n = 10, 
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
		default = ~close,
		data = x,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- rownames(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		"impl_ta_MA",
		as.double(constructed_series[[1]]),
		as.integer(n),
		$DEFAULT_FORMULA
	)

	## readd rownames
	rownames(x) <- x_names

	## return indicator
	x
}

#' @usage NULL
#' @aliases $FUN
#' 
#' @export
$FUN.data.frame <- function(
	x, 
	cols, 
	n = 10, 
	...) {

	as.data.frame(
		NextMethod()
	) 
}

#' @usage NULL
#' @aliases $FUN
#' 
#' @export
$FUN.matrix <- function(
	x, 
	cols,
	n = 10, 
	...) { 
		as.matrix(
			NextMethod()
			) 
			}

#' @usage NULL
#' @aliases $FUN
#' 
#' @export
$FUN.plotly <- function(
	x, 
	cols, 
	n = 10,
	...) { 

	## check that input value
	## 'x' is <plotly>-object
	assert_plotly(x)

	## check that input value
	## 'cols' is a <formula>-objet
	if (!missing(cols)) {
		assert_formula(cols)
	}

	## construct series from 
	## {plotly}-object
	constructed_series <- series(
		x = x,
		formula = cols,
		default = ~close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- $FUN(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		n = n
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {plotly}-object
	plotly_object <- .plotting_environment[["main"]] <- plotly::add_trace(
		.plotting_environment[["main"]],
		data = constructed_indicator,
		x = ~idx,
		y = constructed_indicator[["$ALIAS"]],
		type = "scatter",
		mode = "lines",
		name = sprintf("$ALIAS(%d)", n),
		inherit = FALSE
	)

	plotly_object
 }