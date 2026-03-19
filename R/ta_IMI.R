#' @export
#' @family Momentum Indicator
#'
#' @title Intraday Movement Index
#' @templateVar .title Intraday Movement Index
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun intraday_movement_index
#' @templateVar .family Momentum Indicator
#' @templateVar .formula ~open + close
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @template returns
intraday_movement_index <- function(
	x,
	cols,
	n = 10,
	na.rm = FALSE,
	...
) {
	UseMethod("intraday_movement_index")
}

#' @export
#' @usage NULL
#' @rdname intraday_movement_index
#'
#' @aliases intraday_movement_index
IMI <- intraday_movement_index

#' @usage NULL
#' @aliases intraday_movement_index
#'
#' @export
intraday_movement_index.default <- function(
	x,
	cols,
	n = 10,
	na.rm = FALSE,
	...
) {
	## validate 'cols'-argument
	## if explicitly passed
	if (!missing(cols)) {
		assert_formula(cols)
	}

	## construct series
	## from input
	constructed_series <- series(
		x = cols,
		default = ~ open + close,
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
	x <- .Call(
		"impl_ta_IMI",
		## splice:call:start
		constructed_series[[1]],
		constructed_series[[2]],
		as.integer(n)
		## splice:call:end
	)

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
#' @aliases intraday_movement_index
#'
#' @export
intraday_movement_index.data.frame <- function(
	x,
	cols,
	n = 10,
	na.rm = FALSE,
	...
) {
	map_dfr(
		intraday_movement_index.default(
			x = x,
			cols = cols,
			n = n,
			na.rm = na.rm,
			...
		)
	)
}

#' @usage NULL
#' @aliases intraday_movement_index
#'
#' @export
intraday_movement_index.matrix <- function(
	x,
	cols,
	n = 10,
	na.rm = FALSE,
	...
) {
	intraday_movement_index.default(
		x = x,
		cols = cols,
		n = n,
		na.rm = na.rm,
		...
	)
}

#' @usage NULL
#' @aliases intraday_movement_index
#'
#' @export
intraday_movement_index.plotly <- function(
	x,
	cols,
	n = 10,
	## splice:optional-plotly:start
	## splice:optional-plotly:end
	na.rm = FALSE,
	title,
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
		default = ~ open + close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- intraday_movement_index(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		n = n
	)

	## the constructed indicator
	## always returns excpected
	## columns which can be passed
	## down to add_last_values()
	values_to_extract <- colnames(constructed_indicator)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {plotly}-object
	## splice:plotly-assembly:start
	name <- sprintf(
		"IMI(%d)",
		n
	)

	decorators <- list()

	traces <- list(
		list(y = ~IMI)
	)
	## splice:plotly-assembly:end

	plotly_object <- add_last_value(
		build_plotly(
			init = plotly_init(),
			traces = traces,
			decorators = get0(
				x = "decorators",
				ifnotfound = list()
			),
			name = get0(
				x = "name",
				ifnotfound = NULL
			),
			data = constructed_indicator,
			title = if (missing(title)) {
				"Intraday Movement Index"
			} else {
				title
			}
		),
		data = constructed_indicator[, values_to_extract, drop = FALSE],
		values_to_extract = values_to_extract
	)

	.charting_environment$sub <- c(
		.charting_environment$sub,
		list(plotly_object)
	)

	plotly_object
}
