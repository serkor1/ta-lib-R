#' @export
#' @family Momentum Indicator
#'
#' @title Plus Directional Movement
#' @templateVar .title Plus Directional Movement
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun plus_directional_movement
#' @templateVar .family Momentum Indicator
#' @templateVar .formula ~high + low
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @template returns
plus_directional_movement <- function(
	x,
	cols,
	n = 10,
	...
) {
	UseMethod("plus_directional_movement")
}

#' @export
#' @usage NULL
#' @rdname plus_directional_movement
#'
#' @aliases plus_directional_movement
PLUS_DM <- plus_directional_movement

#' @usage NULL
#' @aliases plus_directional_movement
#'
#' @export
plus_directional_movement.default <- function(
	x,
	cols,
	n = 10,
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
		default = ~ high + low,
		data = x,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- rownames(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		"impl_ta_PLUS_DM",
		## splice:call:start
		constructed_series[[1]],
		constructed_series[[2]],
		as.integer(n)
		## splice:call:end
	)

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases plus_directional_movement
#'
#' @export
plus_directional_movement.data.frame <- function(
	x,
	cols,
	n = 10,
	...
) {
	map_dfr(
		plus_directional_movement.default(
			x = x,
			cols = cols,
			n = n,
			...
		)
	)
}

#' @usage NULL
#' @aliases plus_directional_movement
#'
#' @export
plus_directional_movement.matrix <- function(
	x,
	cols,
	n = 10,
	...
) {
	plus_directional_movement.default(
		x = x,
		cols = cols,
		n = n,
		...
	)
}

#' @usage NULL
#' @aliases plus_directional_movement
#'
#' @export
plus_directional_movement.plotly <- function(
	x,
	cols,
	n = 10,
	## splice:optional-plotly:start
	## splice:optional-plotly:end
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
		default = ~ high + low,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- plus_directional_movement(
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
	## splice:plotly-assembly:start
	name <- sprintf("+DM(%d)", n)

	traces <- list(
		list(y = ~PLUS_DM)
	)
	## splice:plotly-assembly:end

	plotly_object <- build_plotly(
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
			"Plus Directional Movement"
		} else {
			title
		}
	)

	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(plotly_object)
	)

	plotly_object
}
