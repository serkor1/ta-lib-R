#' @export
#' @family $FAMILY
#'
#' @title $TITLE
#' @templateVar .title $TITLE
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun $FUN
#' 
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
$FUN <- function(
	x, 
	cols, $SIG_FORMALS
	...) {
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
	cols, $SIG_FORMALS 
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
		default = $DEFAULT_FORMULA,
		data = x,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- rownames(x)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		"impl_ta_$ALIAS",
		## splice:call:start
		## splice:call:end
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
	cols, $SIG_FORMALS 
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
	cols,$SIG_FORMALS 
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
	cols, $SIG_FORMALS
	## splice:optional-plotly:start
	## splice:optional-plotly:end
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
		default = $DEFAULT_FORMULA,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- $FUN(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		)$SIG_ACTUALS
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {plotly}-object
	## splice:plotly-assembly:start
	## initial scaffold
	## splice:plotly-assembly:end

	plotly_object
 }