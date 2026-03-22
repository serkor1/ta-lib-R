## script:
## objective:
##
## Extract function names and aliases
## from ta_*.R-files in R/
##
## algorithm:
##
##
## 0) helper functions
sides <- function(expr) {
	cl <- expr[[1L]]

	vapply(
		as.list(cl)[-1L],
		function(x) paste(deparse(x), collapse = ""),
		character(1L)
	)
}


find_series <- function(x) {
	if (is.call(x) && identical(x[[1L]], as.name("series"))) {
		return(x)
	}
	if (is.recursive(x)) {
		for (i in seq_along(x)) {
			hit <- find_series(x[[i]])
			if (!is.null(hit)) return(hit)
		}
	}
	NULL
}

## 1) list all ta_ files
##    with full names
list_files <- list.files(
	path = "R",
	pattern = "ta_",
	full.names = TRUE
)


## 2) construct data.frame
##
container <- list()
i <- 1
for (x in list_files) {
	## 1) finde and extract
	##    default formula
	series <- find_series(parse(file = x)[3])
	series <- if (!is.null(series)) series[["default"]] else NULL

	if (is.null(series)) {
		next()
	}

	series <- deparse(series)
	series <- gsub(" ", "", series)

	## 1) parse file
	container[[i]] <- cbind(
		rbind(sides(parse(file = x)[2])),
		series
	)

	i <- i + 1
}

container <- as.data.frame(
	do.call(
		rbind,
		container
	)
)

container$MA <- container$V1 %in%
	c(
		"SMA",
		"EMA",
		"WMA",
		"DEMA",
		"TEMA",
		"TRIMA",
		"KAMA",
		"MAMA",
		"T3"
	)


write.table(
	x = container,
	file = "codegen/table.csv",
	sep = ",",
	row.names = FALSE
)
