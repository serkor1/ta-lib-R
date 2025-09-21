#' @export
#' @family Momentum Indicator
#'
#' @title Aroon
#' @templateVar .title Aroon
#' @templateVar .author Serkan Korkmaz
#' @templateVar .fun aroon
#'
#' @returns
#' A [data.frame]- or [matrix]-object:
#'
#' \describe{
#'  \item{aroon_up <[double]>}{}
#'  \item{aroon_down <[double]>}{}
#' }
#'
#' @template description
aroon <- function(
	x,
	cols,
	n = 10,
	...
) {
	UseMethod(
		generic = "aroon"
	)
}

#' @usage NULL
#' @aliases aroon
#' @export
AROON <- aroon

#' @export
aroon.default <- function(
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

	HL <- series(
		x = cols,
		default = ~ high + low,
		data = x,
		...
	)

	as.data.frame(
		.Call(
			"impl_ta_AROON",
			HL[[1]],
			HL[[2]],
			as.integer(n)
		)
	)
}


#' @usage NULL
#' @aliases aroon
#' @export
aroon.data.frame <- function(
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
#' @aliases aroon
#' @export
aroon.matrix <- function(
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
#' @aliases aroon
#' @export
aroon.plotly <- function(
	x,
	cols,
	n = 10,
	...
) {
	HL <- series(
		x = x,
		formula = cols,
		default = ~ high + low,
		...
	)

	.indicator <- as.data.frame(
		.Call(
			"impl_ta_AROON",
			HL[[1]],
			HL[[2]],
			as.integer(n)
		)
	)

	.indicator$idx <- 1:nrow(.indicator)

	ad_plot <- plotly::plot_ly(
		data = .indicator,
		x = ~idx,
		y = ~aroon_down,
		type = "scatter",
		mode = "lines",
		# line = list(color = ad_col),
		name = "AD",
		legendgroup = "Aroon",
		showlegend = FALSE
	)

	# dashed y = 0 line in the same color
	ad_plot <- plotly::add_lines(
		p = ad_plot,
		x = .indicator$idx,
		y = ~aroon_up,
		# line = list(color = ad_col, dash = "dash"),
		showlegend = FALSE,
		hoverinfo = "skip",
		legendgroup = "Aroon",
		name = "Zero"
	)

	ad_plot <- add_title(
		x = ad_plot,
		text = "Aroon"
	)
	.plotting_environment$sub <- c(
		.plotting_environment$sub,
		list(ad_plot)
	)

	ad_plot
}
