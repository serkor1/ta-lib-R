## script: zzz
## date: 2025-08-13
## author: Serkan Korkmaz, serkor1@duck.com
## objective:
## script start;

## initialize plotting
## environment
.plotting_environment <- new.env(
	parent = emptyenv()
)

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
