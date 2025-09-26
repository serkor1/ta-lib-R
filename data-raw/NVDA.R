## script: NVDA
## objective: Generate NVDA
## data for the R package
## using {quantmod}
##
## 0) load data
NVDA <- quantmod::getSymbols(
	Symbols = "NVDA",
	auto.assign = FALSE,
	from = as.Date("2022-01-01"),
	to = as.Date("2023-12-31")
)[, 1:5]

## 1) rename columns
colnames(NVDA) <- c(
	"open",
	"high",
	"low",
	"close",
	"volume"
)

## 2) convert to matrix
NVDA <- matrix(
	data = NVDA[, 1:5],
	ncol = 5,
	dimnames = list(
		rownames(NVDA),
		colnames(NVDA)
	)
)

## 3) store data
usethis::use_data(
	NVDA,
	overwrite = TRUE
)
