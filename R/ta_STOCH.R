#' @export
#' @family Momentum Indicator
#'
#' @title Stochastic
#' @templateVar .title Stochastic
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun stochastic
#' @templateVar .family Momentum Indicator
#' @templateVar .formula ~ high + low + close
#'
## splice:documentation:start
#' @param fastk ([integer]). Period for the fast-k line.
#' @param slowk ([list]). Period and Moving Average (MA) type  for the slow-k line. [SMA] by default.
#' @param slowd ([list]). Period and Moving Average (MA) type  for the slow-d line. [SMA] by default.
## splice:documentation:end
#'
#' @template description
#' @template returns
stochastic <- function(
	x,
	cols,
	fastk = 5,
	slowk = SMA(n = 10),
	slowd = SMA(n = 8),
	...
) {
	UseMethod("stochastic")
}

#' @export
#' @usage NULL
#' @rdname stochastic
#'
#' @aliases stochastic
STOCH <- stochastic

#' @usage NULL
#' @aliases stochastic
#'
#' @export
stochastic.default <- function(
	x,
	cols,
	fastk = 5,
	slowk = SMA(n = 10),
	slowd = SMA(n = 8),
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
		default = ~ high + low + close,
		data = x,
		...
	)

	## extract rownames
	## for later attachment
	x_names <- rownames(constructed_series)

	## calculate indicator and
	## return as data.frame
	x <- .Call(
		"impl_ta_STOCH",
		## splice:call:start
		constructed_series[[1]],
		constructed_series[[2]],
		constructed_series[[3]],
		as.integer(fastk),
		as.integer(slowk$n),
		as.integer(slowk$maType),
		as.integer(slowd$n),
		as.integer(slowd$maType)
		## splice:call:end
	)

	## readd rownames
	set_rownames(x, x_names)

	## return indicator
	x
}

#' @usage NULL
#' @aliases stochastic
#'
#' @export
stochastic.data.frame <- function(
	x,
	cols,
	fastk = 5,
	slowk = SMA(n = 10),
	slowd = SMA(n = 8),
	...
) {
	map_dfr(
		stochastic.default(
			x = x,
			cols = cols,
			fastk = fastk,
			slowk = slowk,
			slowd = slowd,
			...
		)
	)
}

#' @usage NULL
#' @aliases stochastic
#'
#' @export
stochastic.matrix <- function(
	x,
	cols,
	fastk = 5,
	slowk = SMA(n = 10),
	slowd = SMA(n = 8),
	...
) {
	stochastic.default(
		x = x,
		cols = cols,
		fastk = fastk,
		slowk = slowk,
		slowd = slowd,
		...
	)
}

#' @usage NULL
#' @aliases stochastic
#'
#' @export
stochastic.plotly <- function(
	x,
	cols,
	fastk = 5,
	slowk = SMA(n = 10),
	slowd = SMA(n = 8),
	## splice:optional-plotly:start
	lower_bound = 20,
	upper_bound = 80,
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
		default = ~ high + low + close,
		...
	)

	## construct indicator
	## from the series
	constructed_indicator <- stochastic(
		x = constructed_series,
		cols = rebuild_formula(
			names(constructed_series)
		),
		fastk = fastk,
		slowk = slowk,
		slowd = slowd
	)

	## add conditional idx
	constructed_indicator[["idx"]] <- add_idx(
		constructed_series
	)

	## construct {plotly}-object
	## splice:plotly-assembly:start
	name <- ""

	traces <- list(
		plotly_line(lower_bound),
		plotly_line(upper_bound),
		list(y = ~SlowK),
		list(y = ~SlowD)
	)
	## splice:plotly-assembly:end

	plotly_object <- build_plotly(
		init = plotly_init(),
		traces = traces,
		name = name,
		data = constructed_indicator,
		title = if (missing(title)) {
			"Stochastic"
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
