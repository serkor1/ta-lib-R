## script: series
## objective: create an S3 function
## for preparing data passed into C
## and plotly

series <- function(
	x,
	default,
	...
) {
	target <- if (!missing(x)) x else default
	UseMethod("series", target)
}

#' @export
series.ggplot <- function(
	x,
	default,
	formula,
	...
) {
	if (missing(formula)) {
		formula <- default
	}

	dotsQ <- as.list(substitute(list(...)))[-1L]
	dn <- ...names()
	if (length(dotsQ)) {
		if (is.null(dn)) {
			dn <- rep("", length(dotsQ))
		}
		names(dotsQ) <- dn
	} else {
		dotsQ <- list()
		dn <- character()
	}

	if (!("data" %in% dn)) {
		state <- .chart_state()
		if (is.null(state) || is.null(state$x)) {
			stop(
				"series.ggplot(): no active chart found. ",
				"Call chart() in the same frame before adding indicators.",
				call. = FALSE
			)
		}
		dotsQ$data <- state$x
	}

	out <- as.data.frame(
		do.call(
			series.formula,
			c(list(x = formula, default = default), dotsQ),
			quote = FALSE
		)
	)

	attr(out, "subset") <- eval(dotsQ$subset)

	out
}

#' @export
series.plotly <- function(
	x,
	default,
	formula,
	...
) {
	if (missing(formula)) {
		formula <- default
	}

	dotsQ <- as.list(substitute(list(...)))[-1L]
	dn <- ...names()
	if (length(dotsQ)) {
		if (is.null(dn)) {
			dn <- rep("", length(dotsQ))
		}
		names(dotsQ) <- dn
	} else {
		dotsQ <- list()
		dn <- character()
	}

	# If caller didn't provide data=..., default to the chart's data
	if (!("data" %in% dn)) {
		state <- .chart_state()
		if (is.null(state) || is.null(state$x)) {
			stop(
				"series.plotly(): no active chart found. ",
				"Call chart() in the same frame before adding indicators.",
				call. = FALSE
			)
		}
		dotsQ$data <- state$x
	}

	out <- as.data.frame(
		do.call(
			series.formula,
			c(list(x = formula, default = default), dotsQ),
			quote = FALSE
		)
	)

	## set subset attribute
	## for the
	attr(out, "subset") <- eval(dotsQ$subset)

	out
}

#' @export
series.formula <- function(
	x,
	default,
	...
) {
	# Capture quoted dots; preserve laziness
	dotsQ <- as.list(substitute(list(...)))[-1L]
	dn <- ...names()
	if (length(dotsQ)) {
		names(dotsQ) <- if (is.null(dn)) rep("", length(dotsQ)) else dn
	}

	# Extract 'data' from dots (last-wins if repeated), then remove from dots
	data_expr <- NULL
	if (length(dotsQ)) {
		idx <- which(names(dotsQ) == "data")
		if (length(idx)) {
			data_expr <- dotsQ[[idx[length(idx)]]]
			dotsQ <- dotsQ[-idx] # avoid passing data twice
		}
	}
	if (is.null(data_expr)) {
		stop("series(): 'data' must be supplied via '...'.", call. = FALSE)
	}
	data <- eval(data_expr, envir = parent.frame())
	if (!is.data.frame(data)) {
		data <- as.data.frame(data)
	}

	# Use default formula if missing
	if (missing(x)) {
		x <- default
	} else {
		## assert formula length
		## relative to the default
		##
		## NOTE: It is OK to pass a longer
		##       formula than the expected
		##
		##       The function will just use what it
		##       needs anyways.
		formula_length <- length(all.vars(x))
		default_length <- length(all.vars(default))

		assert(
			x = formula_length >= default_length,
			call = sys.call(sys.parent()),

			## expected
			paste0("Expected 'cols' length to be ", default_length, "."),

			## actual
			paste0("Got length ", formula_length, "."),

			## default formula
			paste0(
				"Uses ",
				paste0("'", all.vars(default), "'", collapse = ", "),
				" by default."
			)
		)
	}

	assert_column_names(
		formula = x,
		available_variables = colnames(data)
	)

	# Fast path: no extra args -> select columns directly
	if (length(dotsQ) == 0) {
		out <- data[, all.vars(x), drop = FALSE]
	} else {
		# Model frame with exactly one 'data'
		out <- do.call(
			stats::model.frame,
			c(list(formula = x, data = data), dotsQ),
			quote = FALSE
		)
	}

	## set subset attribute
	## for the
	attr(out, "subset") <- eval(dotsQ$subset)

	as.data.frame(
		out
	)
}
