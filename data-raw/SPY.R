## script: SPY
## objective: Generate SPY
## data for the R package
## using {quantmod}
##
## 0) load data
SPY <- quantmod::getSymbols(
	Symbols = "SPY",
	auto.assign = FALSE,
	from = as.Date("2023-01-01"),
	to = as.Date("2024-12-31")
)[, 1:5]

## 1) rename columns
colnames(SPY) <- c(
	"open",
	"high",
	"low",
	"close",
	"volume"
)

## 2) convert to matrix
SPY <- matrix(
	data = SPY[, 1:5],
	ncol = 5,
	dimnames = list(
		rownames(SPY),
		colnames(SPY)
	)
)

## 3) store data
usethis::use_data(
	SPY,
	overwrite = TRUE
)
