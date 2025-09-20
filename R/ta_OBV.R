#' @export
#' @family Volume Indicator
#'
#' @title On-Balance Volume
#'
#' @templateVar .title On-Balance Volume
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun on_balance_volume
#'
#' @template description
on_balance_volume <- function(
	x,
	cols,
	n = 10,
	...
) {
	UseMethod("on_balance_volume")
}

#' @usage NULL
#' @aliases on_balance_volume
#' @export
OBV <- on_balance_volume

#' @usage NULL
#' @aliases on_balance_volume
#' @export
on_balance_volume.default <- function(
	x,
	cols,
	n = 10,
	...
) {
	## check input
	## cols if passed
	if (!missing(cols)) {
		assert(
			is.formula(cols),
			paste0(
				"'cols' has to be <",
				class(~s),
				">. ",
				"Got <",
				class(cols),
				">."
			)
		)
		assert(
			length(all.vars(cols)) == 2,
			paste0(
				"'cols' has to be length 2. ",
				"Got length ",
				length(all.vars(cols))
			)
		)
	}

	CV <- series(
		x = cols,
		default = ~ close + volume,
		data = x,
		...
	)

	assert(n >= 2)

	## 1) pass `x` assuming that it
	##    follows OHLC-V structure
	output <- as.data.frame(
		.Call(
			"impl_ta_OBV",
			CV[[1]],
			CV[[2]]
		)
	)

	colnames(output)[1] <- "OBV"

	return(output)
}

#' @usage NULL
#' @aliases on_balance_volume
#' @export
on_balance_volume.data.frame <- function(
	x,
	cols,
	n = 10,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases on_balance_volume
#' @export
on_balance_volume.matrix <- function(
	x,
	cols,
	n = 10,
	...
) {
	as.matrix(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases on_balance_volume
#' @export
on_balance_volume.plotly <- function(
	x,
	cols,
	n = 10,
	...
) {
	## prepare series
	## from
	CV <- series(
		x = x,
		formula = cols,
		default = ~ close + volume,
		...
	)

	## calculate acceleration
	## bands and return as
	## data.frame
	.indicator <- as.data.frame(
		.Call(
			"impl_ta_OBV",
			CV[[1]],
			CV[[2]]
		)
	)

	colnames(.indicator)[1] <- "OBV"

	.indicator$idx <- 1:nrow(.indicator)

	## Create
	output <- plotly::plot_ly(
		data = .indicator,
		x = ~idx,
		y = ~OBV,
		type = "scatter",
		mode = "lines",
		# line = list(color = ad_col),
		name = "On-Balance Volume",
		legendgroup = "obv",
		showlegend = TRUE
	)

	output <- add_title(
		x = output,
		text = "On-Balance Volume (OBV)"
	)
	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(output)
	)

	output
}
