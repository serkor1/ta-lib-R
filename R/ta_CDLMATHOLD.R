#' @export
#' @family Pattern Recognition
#'
#' @title Mat Hold
#' @templateVar .title Mat Hold
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun mat_hold
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
mat_hold <- function(
	x,
	cols,
	eps = 0,
	...
) {
	UseMethod("mat_hold")
}

#' @export
#' @usage NULL
#' @rdname mat_hold
#'
#' @aliases mat_hold
CDLMATHOLD <- mat_hold

#' @usage NULL
#' @aliases mat_hold
#'
#' @export
mat_hold.default <- function(
	x,
	cols,
	eps = 0,
	...
) {
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
		x = cols,
		default = ~ open + high + low + close,
		data = x,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- rownames(x)

	## calculate indicator and
	## return as data.frame
	x <- as.matrix(
		.Call(
			"impl_ta_CDLMATHOLD",
			constructed_series[[1]],
			constructed_series[[2]],
			constructed_series[[3]],
			constructed_series[[4]],
			eps = eps,
			normalize
		)
	)

	## add column name
	colnames(x) <- "CDLMATHOLD"

	## readd rownames
	rownames(x) <- x_names

	## return indicator
	x
}

#' @usage NULL
#' @aliases mat_hold
#'
#' @export
mat_hold.data.frame <- function(
	x,
	cols,
	eps = 0,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases mat_hold
#'
#' @export
mat_hold.matrix <- function(
	x,
	cols,
	eps = 0,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases mat_hold
#'
#' @export
mat_hold.plotly <- function(
	x,
	cols,
	eps = 0,
	...
) {
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
		default = ~ open + high + low + close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- mat_hold(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		eps = eps
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {plotly}-object
	plotly_object <- .plotting_environment[["main"]] <- pattern(
		p = .plotting_environment[["main"]],
		x = constructed_indicator,
		high = constructed_series[[2]],
		low = constructed_series[[3]],
		pattern_name = "mat_hold",
		agnostic = FALSE
	)

	plotly_object
}
