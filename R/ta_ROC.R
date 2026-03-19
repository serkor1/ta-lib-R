#' @export
#' @family Momentum Indicator
#'
#' @title Rate of Change
#' @templateVar .title Rate of Change
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun rate_of_change
#' @templateVar .family Momentum Indicator
#' @templateVar .formula ~close
#'
## splice:documentation:start
## splice:documentation:end
#'
#' @template description
#' @template returns
rate_of_change <- function(
	x,
	cols,
	n = 10,
	na.rm = FALSE,
	...
) {
	UseMethod("rate_of_change")
}

#' @export
#' @usage NULL
#' @rdname rate_of_change
#'
#' @aliases rate_of_change
ROC <- rate_of_change

#' @usage NULL
#' @aliases rate_of_change
#'
#' @export
rate_of_change.default <- function(
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
		"impl_ta_ROC",
		## splice:call:start
		constructed_series[[1]],
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
#' @aliases rate_of_change
#'
#' @export
rate_of_change.data.frame <- function(
	x,
	cols,
	n = 10,
	na.rm = FALSE,
	...
) {
	map_dfr(
		rate_of_change.default(
			x = x,
			cols = cols,
			n = n,
			na.rm = na.rm,
			...
		)
	)
}

#' @usage NULL
#' @aliases rate_of_change
#'
#' @export
rate_of_change.matrix <- function(
	x,
	cols,
	n = 10,
	na.rm = FALSE,
	...
) {
	rate_of_change.default(
		x = x,
		cols = cols,
		n = n,
		na.rm = na.rm,
		...
	)
}

#' @usage NULL
#' @aliases rate_of_change
#'
#' @export
rate_of_change.numeric <- function(
	x,
	cols,
	n = 10,
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
		"impl_ta_ROC",
		## splice:numeric:start
		as.double(x),
		as.integer(n)
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
#' @aliases rate_of_change
#'
#' @export
rate_of_change.plotly <- function(
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
		default = ~close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- rate_of_change(
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
		"ROC(%d)",
		n
	)

	traces <- list(
		list(
			y = ~ROC
		)
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
				"Rate of Change"
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
