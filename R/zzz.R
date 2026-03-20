## script: zzz
## date: 2025-08-13
## author: Serkan Korkmaz, serkor1@duck.com
## objective:
## script start;

## initialize plotting
## environment
.chart_environment <- new.env(
	parent = emptyenv()
)

## initialize theme
## environment
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

## actions on attach
## and load
.onAttach <- function(
	libname,
	pkgname,
	...
) {
	## initialize TA-Lib
	## on attach
	.Call(
		"initialize_ta_lib",
		PACKAGE = pkgname
	)

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
	.Call(
		"initialize_ta_lib",
		PACKAGE = pkgname
	)
}

## actions on attach
## and unload
.onDetach <- function(
	libpath,
	...
) {
	## reset candles on
	## detach
	.Call(
		"reset_candle_setting"
	)

	## shutdown TA-Lib
	## on detach
	.Call(
		"shutdown_ta_lib",
		PACKAGE = "talib"
	)
}

.onUnload <- function(
	libpath,
	...
) {
	## reset candles on
	## unload
	.Call(
		"reset_candle_setting"
	)

	## shutdown TA-Lib
	## on unload
	.Call(
		"shutdown_ta_lib",
		PACKAGE = "talib"
	)
}

## script end;
