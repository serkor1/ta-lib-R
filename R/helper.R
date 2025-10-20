## script: helper functions
## for the small repetitative tasks
##
## output values
na_pad <- function(x, n = 5) {
	## some functions are wrappers
	## of eachother so it does not
	## respect the 'length in, length out'-principle
	##
	## this function will pad the output with leading
	## <na> to avoid length mismatches
	if (n <= 0L) {
		return(x)
	}

	rbind(
		stats::setNames(
			as.data.frame(
				matrix(
					NA_real_,
					nrow = n,
					ncol = ncol(x)
				)
			),
			colnames(x)
		),
		x
	)
}

to_title <- function(
	x
) {
	## remove underscores
	## if preset
	x <- gsub(pattern = "_", replacement = " ", x = x)
	gsub("\\b(.)", "\\U\\1", tolower(x), perl = TRUE)
}

## input values
map_maType_call <- function(call_expr) {
	args <- as.list(call_expr)[-1L]
	head_chr <- as.character(call_expr[[1L]])
	fun_name <- utils::tail(head_chr, 1L)

	maType <- switch(
		fun_name,
		SMA = 0L,
		EMA = 1L,
		WMA = 2L,
		DEMA = 3L,
		TEMA = 4L,
		TRIMA = 5L,
		KAMA = 6L,
		MAMA = 7L,
		T3 = 8L,
		stop(sprintf("Unknown MA type: %s", fun_name))
	)

	n_val <- args[["n"]]

	list(
		n = as.integer(n_val),
		maType = maType
	)
}

rebuild_formula <- function(
	x,
	exclude = "idx"
) {
	if (!is.character(x)) {
		x <- names(x)
	}
	## this function removes
	## idx and rebuilds the passed
	## series as formulas
	idx <- grepl(
		pattern = exclude,
		x = x,
		ignore.case = TRUE
	)

	stats::reformulate(
		x[!idx]
	)
}

add_idx <- function(x) {
	## store idx
	idx <- .plotting_environment$idx$label

	if (!is.null(idx)) {
		idx[
			if (is.null(attributes(x)$subset)) {
				1:nrow(x)
			} else {
				attributes(x)$subset
			}
		]
	} else {
		1:nrow(x)
	}
}

main_chart_exists <- function() {
	!is.null(.plotting_environment$main)
}
