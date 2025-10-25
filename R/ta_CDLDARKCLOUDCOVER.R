#' @export
#' @family Pattern Recognition
#'
#' @title Dark Cloud Cover
#' @templateVar .title Dark Cloud Cover
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun dark_cloud_cover
#'
#' @returns
#' An object of same [class] and [length] of `x`:
#'
#' \describe{
#'  \item{CDLDARKCLOUDCOVER ([integer])}{Dark Cloud Cover pattern}
#' }
#'
#' Pattern codes depend on `options(talib.normalize)`:
#'
#' * If `TRUE`: `1` = identified pattern; `-1` = identified bearish pattern.
#' * If `FALSE`: `100` = identified pattern; `-100` = identified bearish pattern.
#' * `0` = no pattern.
#'
#'
#' @template description
dark_cloud_cover <- function(
	x,
	cols,
	eps = 0,
	...
) {
	UseMethod("dark_cloud_cover")
}

#' @export
#' @usage NULL
#' @rdname dark_cloud_cover
#'
#' @aliases dark_cloud_cover
CDLDARKCLOUDCOVER <- dark_cloud_cover

#' @usage NULL
#' @aliases dark_cloud_cover
#'
#' @export
dark_cloud_cover.default <- function(
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
	x_names <- rownames(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- as.matrix(
		.Call(
			"impl_ta_CDLDARKCLOUDCOVER",
			constructed_series[[1]],
			constructed_series[[2]],
			constructed_series[[3]],
			constructed_series[[4]],
			eps = eps,
			normalize
		)
	)

	## add column name
	colnames(x) <- "CDLDARKCLOUDCOVER"

	## readd rownames
	rownames(x) <- x_names

	## return indicator
	x
}

#' @usage NULL
#' @aliases dark_cloud_cover
#'
#' @export
dark_cloud_cover.data.frame <- function(
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
#' @aliases dark_cloud_cover
#'
#' @export
dark_cloud_cover.matrix <- function(
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
#' @aliases dark_cloud_cover
#'
#' @export
dark_cloud_cover.plotly <- function(
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
	constructed_indicator <- dark_cloud_cover(
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
		pattern_name = "dark_cloud_cover",
		agnostic = FALSE
	)

	plotly_object
}
