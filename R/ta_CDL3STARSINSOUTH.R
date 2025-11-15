#' @export
#' @family Pattern Recognition
#'
#' @title Three Stars in the South
#' @templateVar .title Three Stars in the South
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun three_stars_in_the_south
#' @templateVar .family Cycle Indicator
#' @templateVar .formula ~open + high + low + close
#'
#' @returns
#' An object of same [class] and [length] of `x`:
#'
#' \describe{
#'  \item{CDL3STARSINSOUTH}{[integer]}
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
three_stars_in_the_south <- function(
	x,
	cols,
	...
) {
	UseMethod("three_stars_in_the_south")
}

#' @export
#' @usage NULL
#' @rdname three_stars_in_the_south
#'
#' @aliases three_stars_in_the_south
CDL3STARSINSOUTH <- three_stars_in_the_south

#' @usage NULL
#' @aliases three_stars_in_the_south
#'
#' @export
three_stars_in_the_south.default <- function(
	x,
	cols,
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

	## calculate indicator and
	## return as data.frame
	x <- as.matrix(
		.Call(
			"impl_ta_CDL3STARSINSOUTH",
			constructed_series[[1]],
			constructed_series[[2]],
			constructed_series[[3]],
			constructed_series[[4]],
			normalize
		)
	)

	## add column name
	colnames(x) <- "CDL3STARSINSOUTH"

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases three_stars_in_the_south
#'
#' @export
three_stars_in_the_south.data.frame <- function(
	x,
	cols,
	...
) {
	map_dfr(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases three_stars_in_the_south
#'
#' @export
three_stars_in_the_south.matrix <- function(
	x,
	cols,
	...
) {
	NextMethod()
}

#' @usage NULL
#' @aliases three_stars_in_the_south
#'
#' @export
three_stars_in_the_south.plotly <- function(
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
	constructed_indicator <- three_stars_in_the_south(
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
		pattern_name = "three_stars_in_the_south",
		agnostic = FALSE
	)

	plotly_object
}
