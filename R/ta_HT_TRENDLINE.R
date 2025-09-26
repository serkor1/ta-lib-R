#' @export
#' @family Overlap Study
#'
#' @title Hilbert Transform - Instantaneous Trendline
#'
#' @templateVar .title Hilbert Transform - Instantaneous Trendline
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun ht_trendline
#'
#' @template description
ht_trendline <- function(
	x,
	cols,
	...
) {
	UseMethod("ht_trendline")
}

#' @export
#'
#' @usage NULL
#'
#' @rdname ht_trendline
#' @aliases ht_trendline
HT_TRENDLINE <- ht_trendline

#' @usage NULL
#' @aliases ht_trendline
#' @export
ht_trendline.default <- function(
	x,
	cols,
	...
) {
	if (!missing(cols)) {
		## check for formula
		assert(
			is.formula(cols),
			paste0(
				"'cols' has to be <",
				class(~s),
				">.",
				"Got <",
				class(cols),
				">."
			)
		)

		assert(
			length(all.vars(cols)) == 1,
			paste0(
				"'cols' has to be length 1. ",
				"Got length ",
				length(all.vars(cols))
			)
		)
	}

	## extract series
	x <- series(
		x = cols,
		default = ~open,
		data = x,
		...
	)

	x <- as.data.frame(
		.Call(
			"impl_ta_HT_TRENDLINE",
			x[[1]]
		)
	)

	colnames(x)[1] <- "ht_trendline"

	return(x)
}


#' @usage NULL
#' @aliases ht_trendline
#' @export
ht_trendline.data.frame <- function(
	x,
	cols,
	...
) {
	as.data.frame(
		NextMethod()
	)
}

#' @usage NULL
#' @aliases ht_trendline
#' @export
ht_trendline.numeric <- function(
	x,
	cols,
	...
) {
	## determine branch
	## if its a matrix call
	## matrix method and end the function
	##
	## NOTE: this is necessary as matrix are
	##       internally doubles
	if (is.matrix(x)) {
		output <- NextMethod()

		return(output)
	}

	## treat 'x' as a vector
	##
	if (!missing(cols)) {
		warning(
			"'cols' have been passed but is unused in for vectors"
		)
	}

	.Call(
		"impl_ta_HT_TRENDLINE",
		x
	)
}

#' @usage NULL
#' @aliases ht_trendline
#' @export
ht_trendline.matrix <- function(
	x,
	cols,
	...
) {
	as.matrix(
		NextMethod()
	)
}


#' @rdname ht_trendline
#' @usage NULL
#' @export
ht_trendline.plotly <- function(
	x,
	cols,
	...
) {
	## prepare series
	## from
	x <- as.data.frame(
		series(
			x = x,
			formula = cols,
			default = ~open,
			...
		)
	)

	## indicator
	.indicator <- ht_trendline.default(
		x = x,
		cols = cols
	)
	.indicator$idx <- 1:nrow(.indicator)

	for (i in 1:ncol(x)) {
		local({
			j <- i
			.plotting_environment$main <- plotly::add_trace(
				.plotting_environment$main,
				data = .indicator,
				x = ~idx,
				y = ~ .indicator[, j],
				type = "scatter",
				mode = "lines",
				name = sprintf("Trendline"),
				inherit = FALSE
			)
		})
	}

	.plotting_environment$main
}
