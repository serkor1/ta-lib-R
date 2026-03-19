#' @export
#' @family Momentum Indicator
#'
#' @title Percentage Price Oscillator
#' @templateVar .title Percentage Price Oscillator
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun percentage_price_oscillator
#' @templateVar .family Momentum Indicator
#' @templateVar .formula ~close
#'
## splice:documentation:start
#' @param fast ([integer]). Period for the fast Moving Average (MA).
#' @param slow ([integer]). Period for the slow Moving Average (MA).
#' @param ma ([list]). The type of Moving Average (MA) used for the `fast` and `slow` MA. [SMA] by default.
## splice:documentation:end
#'
#' @template description
#' @template returns
percentage_price_oscillator <- function(
	x,
	cols,
	fast = 7,
	slow = 14,
	ma = SMA(n = 10),
	na.rm = FALSE,
	...
) {
	UseMethod("percentage_price_oscillator")
}

#' @export
#' @usage NULL
#' @rdname percentage_price_oscillator
#'
#' @aliases percentage_price_oscillator
PPO <- percentage_price_oscillator

#' @usage NULL
#' @aliases percentage_price_oscillator
#'
#' @export
percentage_price_oscillator.default <- function(
	x,
	cols,
	fast = 7,
	slow = 14,
	ma = SMA(n = 10),
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
		default = ~close,
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
		"impl_ta_PPO",
		## splice:call:start
		constructed_series[[1]],
		as.integer(fast),
		as.integer(slow),
		ma$maType
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
#' @aliases percentage_price_oscillator
#'
#' @export
percentage_price_oscillator.data.frame <- function(
	x,
	cols,
	fast = 7,
	slow = 14,
	ma = SMA(n = 10),
	na.rm = FALSE,
	...
) {
	map_dfr(
		percentage_price_oscillator.default(
			x = x,
			cols = cols,
			fast = fast,
			slow = slow,
			ma = ma,
			na.rm = na.rm,
			...
		)
	)
}

#' @usage NULL
#' @aliases percentage_price_oscillator
#'
#' @export
percentage_price_oscillator.matrix <- function(
	x,
	cols,
	fast = 7,
	slow = 14,
	ma = SMA(n = 10),
	na.rm = FALSE,
	...
) {
	percentage_price_oscillator.default(
		x = x,
		cols = cols,
		fast = fast,
		slow = slow,
		ma = ma,
		na.rm = na.rm,
		...
	)
}

#' @usage NULL
#' @aliases percentage_price_oscillator
#'
#' @export
percentage_price_oscillator.numeric <- function(
	x,
	cols,
	fast = 7,
	slow = 14,
	ma = SMA(n = 10),
	na.rm = FALSE,
	...
) {
	## warn if 'cols' have been
	## passed just to make sure
	## the user knows its not possible
	## or relevant
	if (!missing(cols)) {
		warning("'cols' is passed but is unused for vectors.")
	}

	## handle missing values
	if (na.rm) {
		na_info <- strip_na_vector(x)
		x <- na_info$x
	}

	## pass the argument directly
	## to 'C'
	x <- .Call(
		"impl_ta_PPO",
		## splice:numeric:start
		as.double(x),
		as.integer(fast),
		as.integer(slow),
		ma$maType
		## splice:numeric:end
	)

	## check if it has 'dims'
	## and convert to double if
	## not to honor the 'type-safety'-esque
	## approach
	##
	## NOTE: this adds a few ns overhead but
	##       its a robust alternative to code it
	##       manually. Any suggestions are welcome
	if (is.null(dim(x))) {
		x <- as.double(x)
	}

	## re-expand NA positions
	if (na.rm && !is.null(na_info$na_idx)) {
		x <- reexpand_na_vector(x, na_info)
	}

	x
}

#' @usage NULL
#' @aliases percentage_price_oscillator
#'
#' @export
percentage_price_oscillator.plotly <- function(
	x,
	cols,
	fast = 7,
	slow = 14,
	ma = SMA(n = 10),
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
		default = ~close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- percentage_price_oscillator(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		fast = fast,
		slow = slow,
		ma = ma
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
		"PPO(%d, %d)",
		fast,
		slow
	)

	traces <- list(
		list(y = ~PPO)
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
				"Percentage Price Oscillator"
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
