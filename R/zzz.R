## script: zzz
## date: 2025-08-13
## author: Serkan Korkmaz, serkor1@duck.com
## objective:
## script start;

## ---- per-pipeline chart state ----
##
## Charts use per-frame state instead of a package-level environment.
## chart() stashes a fresh state env in its caller's evaluation frame
## under .TALIB_STATE_KEY; indicator() and helpers retrieve it via a
## call-stack walk (dynGet). This keeps two parallel chart() pipelines
## from colliding (Shiny, futures, etc.) without taking a dependency
## on shiny / plumber / future / promises.
##
## The constraint: chart() and the subsequent indicator() calls must
## live in the same enclosing frame (script chunk, function body,
## render block, etc.). Splitting them across unrelated function
## bodies is unsupported - same as base R's plot() / lines().

.TALIB_STATE_KEY <- ".talib_chart_state"

## Create a fresh state env in the caller's frame and return it.
## Pass envir = parent.frame() explicitly from the call site - the
## default would resolve to .chart_state_create()'s OWN caller frame,
## which is one level too deep.
.chart_state_create <- function(envir) {
	env <- new.env(parent = emptyenv())
	assign(.TALIB_STATE_KEY, env, envir = envir)
	env
}

## Look up the active state env by walking the call stack.
## Returns NULL if no chart() has been called in the current frame
## chain - callers can use this to detect standalone-mode indicator()
## (where data is supplied explicitly).
##
## NOTE: dynGet() with default minframe = 1L skips the global env;
## we walk explicitly and add a globalenv() fallback so that REPL-
## and script-level chart()/indicator() pairs work too.
.chart_state <- function() {
	n <- sys.nframe() - 1L
	while (n >= 1L) {
		env <- sys.frame(n)
		if (exists(.TALIB_STATE_KEY, envir = env, inherits = FALSE)) {
			return(get(.TALIB_STATE_KEY, envir = env, inherits = FALSE))
		}
		n <- n - 1L
	}
	if (exists(.TALIB_STATE_KEY, envir = globalenv(), inherits = FALSE)) {
		return(get(.TALIB_STATE_KEY, envir = globalenv(), inherits = FALSE))
	}
	NULL
}

## Drop the active state env from the caller's frame, if present.
## Used by chart() called with no arguments to wipe the pipeline.
.chart_state_reset <- function(envir) {
	if (exists(.TALIB_STATE_KEY, envir = envir, inherits = FALSE)) {
		rm(list = .TALIB_STATE_KEY, envir = envir)
	}
	invisible(NULL)
}

## ---- theme state ----
##
## Themes are session-wide preferences (set_theme() applies forward
## to all subsequent chart() calls), so .chart_variables stays
## package-level intentionally.
.chart_variables <- new.env(
	parent = emptyenv()
)

## set default theme
## candle-colors
.chart_variables$bearish_body <- "#4682B4"
.chart_variables$bearish_wick <- "#4682B4"
.chart_variables$bearish_border <- "#3B6A93"
.chart_variables$bullish_body <- "#E0FFFF"
.chart_variables$bullish_wick <- "#E0FFFF"
.chart_variables$bullish_border <- "#C0D9D9"

## general-colors
.chart_variables$background_color <- "#141414"
.chart_variables$foreground_color <- "#E0FFFF"
.chart_variables$text_color <- "#E0FFFF"

## colorway
.chart_variables$colorway <- c(
	"#E0FFFF",
	"#B5F3FF",
	"#7DD3FC",
	"#5BC0EB",
	"#4682B4",
	"#2E86AB",
	"#00B3B8",
	"#44D7B6",
	"#C792EA",
	"#F6C177"
)

## gridcolor
.chart_variables$gridcolor <- "#232A30"

## threshold line color
.chart_variables$threshold_color <- "#5A6270"

## package hooks
##
## .onLoad initializes TA-Lib when the namespace is loaded (including via
## `::` without attach). .onAttach only emits the startup banner; the C
## initializer lives in .onLoad to avoid running TA_Initialize twice on
## library(talib).
##
## Symmetrically, teardown lives in .onUnload only. A bare detach()
## leaves the namespace loaded, so resetting candle settings / shutting
## down TA-Lib there would strand a half-initialized library; .onUnload
## fires exactly when the namespace is truly gone.
.onAttach <- function(
	libname,
	pkgname,
	...
) {
	## startup message when
	## library(talib)
	packageStartupMessage(
		paste0(
			"Loading {",
			utils::packageName(),
			"} v",
			utils::packageVersion(pkgname)
		)
	)
}

.onLoad <- function(
	libname,
	pkgname,
	...
) {
	## initialize TA-Lib
	## on load
	.Call(C_initialize_ta_lib)
}

.onUnload <- function(
	libpath,
	...
) {
	## reset candles on
	## unload
	.Call(C_reset_candle_setting)

	## shutdown TA-Lib
	## on unload
	.Call(C_shutdown_ta_lib)
}

## script end;
