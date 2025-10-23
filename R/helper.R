## script: helper functions
## for the small repetitative tasks
##
## output values
to_title <- function(
	x
) {
	## remove underscores
	## if preset
	x <- gsub(pattern = "_", replacement = " ", x = x)
	gsub("\\b(.)", "\\U\\1", tolower(x), perl = TRUE)
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
