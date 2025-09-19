# script: zzz
# date: 2025-08-13
# author: Serkan Korkmaz, serkor1@duck.com
# objective:
# script start;

.plotting_environment <- new.env(
	parent = emptyenv()
)

.onAttach <- function(
	libname,
	pkgname,
	...
) {
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
	.Call(
		"initialize_ta_lib",
		PACKAGE = pkgname
	)
}

.onDetach <- function(
	libpath,
	...
) {
	.Call(
		"shutdown_ta_lib",
		PACKAGE = "talib"
	)
}

.onUnload <- function(
	libpath,
	...
) {
	.Call(
		"shutdown_ta_lib",
		PACKAGE = "talib"
	)
}

# script end;
