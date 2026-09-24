## script: GOOGL
## objective: Generate GOOGL
## data for the R package
## using {quantmod}
##
## 1) load data
GOOGL <- quantmod::getSymbols(
	Symbols = "GOOGL",
	auto.assign = FALSE,
	from = as.Date("2019-01-01"),
	to = as.Date("2021-12-31")
)

## 2) store data
usethis::use_data(
	GOOGL,
	overwrite = TRUE
)
