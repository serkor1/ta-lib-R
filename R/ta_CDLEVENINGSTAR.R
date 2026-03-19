#' @export
#' @family Pattern Recognition
#'
#' @title Evening Star
#' @templateVar .title Evening Star
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun evening_star
#' @templateVar .family Pattern Recognition
#' @templateVar .formula ~open + high + low + close
#'
#' @returns
#' An object of same [class] and [length] of `x`:
#'
#' \describe{
#'  \item{CDLEVENINGSTAR}{[integer]}
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
evening_star <- function(
	x,
	cols,
	eps = 0,
	na.rm = FALSE,
	...
) {
	UseMethod("evening_star")
}

#' @export
#' @usage NULL
#' @rdname evening_star
#'
#' @aliases evening_star
CDLEVENINGSTAR <- evening_star

#' @usage NULL
#' @aliases evening_star
#'
#' @export
evening_star.default <- function(
	x,
	cols,
	eps = 0,
	na.rm = FALSE,
	...
) {
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
		x = cols,
		default = ~ open + high + low + close,
		data = x,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- rownames(constructed_series)

	## handle missing values
	if (na.rm) {
		na_info <- strip_na(constructed_series, x_names)
		constructed_series <- na_info$series
		x_names <- na_info$x_names
	}

	## calculate indicator and
	## return as data.frame
	x <- as.matrix(
		.Call(
			"impl_ta_CDLEVENINGSTAR",
			constructed_series[[1]],
			constructed_series[[2]],
			constructed_series[[3]],
			constructed_series[[4]],
			eps,
			normalize
		)
	)

	## add column name
	colnames(x) <- "CDLEVENINGSTAR"

	## re-expand NA rows
	if (na.rm && !is.null(na_info$na_idx)) {
		x <- reexpand_na(x, na_info)
		x_names <- na_info$x_names_all
	}

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases evening_star
#'
#' @export
evening_star.data.frame <- function(
	x,
	cols,
	eps = 0,
	na.rm = FALSE,
	...
) {
	map_dfr(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases evening_star
#'
#' @export
evening_star.matrix <- function(
	x,
	cols,
	eps = 0,
	na.rm = FALSE,
	...
) {
	NextMethod()
}

#' @usage NULL
#' @aliases evening_star
#'
#' @export
evening_star.plotly <- function(
	x,
	cols,
	eps = 0,
	na.rm = FALSE,
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
	constructed_indicator <- evening_star(
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
		pattern_name = "evening_star",
		agnostic = FALSE
	)

	plotly_object
}
