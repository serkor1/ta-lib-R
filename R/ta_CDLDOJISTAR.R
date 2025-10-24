#' @export
#' @family Pattern Recognition
#'
#' @title Doji Star
#' @templateVar .title Doji Star
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun doji_star
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
doji_star <- function(
	x,
	cols,
	...
) {
	UseMethod("doji_star")
}

#' @export
#' @usage NULL
#' @rdname doji_star
#'
#' @aliases doji_star
CDLDOJISTAR <- doji_star

#' @usage NULL
#' @aliases doji_star
#'
#' @export
doji_star.default <- function(
	x,
	cols,
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
			"impl_ta_CDLDOJISTAR",
			constructed_series[[1]],
			constructed_series[[2]],
			constructed_series[[3]],
			constructed_series[[4]],
			normalize
		)
	)

	## add column name
	colnames(x) <- "CDLDOJISTAR"

	## readd rownames
	rownames(x) <- x_names

	## return indicator
	x
}

#' @usage NULL
#' @aliases doji_star
#'
#' @export
doji_star.data.frame <- function(
	x,
	cols,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases doji_star
#'
#' @export
doji_star.matrix <- function(
	x,
	cols,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases doji_star
#'
#' @export
doji_star.plotly <- function(
	x,
	cols,
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
	constructed_indicator <- doji_star(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		)
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
		pattern_name = "doji_star",
		agnostic = FALSE
	)

	plotly_object
}
