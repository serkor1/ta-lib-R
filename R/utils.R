## script: utility functions
## for the small essential tasks
##
## assert input values
## with and without wrappers
assert <- function(
	x,
	call = sys.call(),
	...
) {
	## exit the function if x is
	## TRUE
	if (x) {
		return(invisible(TRUE))
	}

	system_message <- if (...length()) {
		paste(...)
	} else {
		"Assertion failed"
	}

	stop(
		simpleError(
			message = system_message,
			call = call
		)
	)
}

assert_formula <- function(x) {
	## NOTE: this **could** potentially
	##       be used in
	## assert that it is a formula
	##
	assert(
		x = is.formula(x),
		call = sys.call(sys.parent()),
		"Expected",
		paste0("'", substitute(x), "'"),
		"as <formula>.",
		"Got",
		paste0(
			"<",
			class(x),
			">."
		)
	)
}


assert_plotly <- function(x) {
	assert(
		x = is.plotly(x),
		call = sys.call(sys.parent()),
		"Expected",
		paste0("'", substitute(x), "'"),
		"as <plotly>.",
		"Got",
		paste0(
			"<",
			class(x),
			">."
		)
	)
}


## class related utility
## functions
is.number <- function(x) {
	is.numeric(x) || is.integer(x)
}

is.formula <- function(x) {
	inherits(x, "formula")
}

is.plotly <- function(x) {
	inherits(x, "plotly")
}

reclass <- function(x, ...) {
	class(x) <- c(class(x), ...)
}

## list operations
flatten <- function(x) {
	if (!inherits(x, "list")) {
		list(x)
	} else {
		unlist(c(lapply(x, flatten)), recursive = FALSE)
	}
}

## extract input name
input_name <- function(x) {
	if (is.call(x) && as.character(x[[1L]]) %in% c("::", ":::")) {
		x <- x[[3L]]
	}
	deparse(x)
}

## check for args
has_arg <- function(name) {
	## shamelessly stolen from
	## {methods}
	aname <- as.character(substitute(name))
	fnames <- names(
		formals(
			sys.function(sys.parent())
		)
	)

	if (is.na(match(aname, fnames))) {
		if (is.na(match("...", fnames))) {
			FALSE
		} else {
			dotsCall <- eval(quote(substitute(list(...))), sys.parent())
			!is.na(match(aname, names(dotsCall)))
		}
	} else {
		eval(substitute(!missing(name)), sys.frame(sys.parent()))
	}
}
