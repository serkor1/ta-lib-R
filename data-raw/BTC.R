## script: BTC
## objective: Generate BTC
## data for the R package
## using {cryptoQuotes}
##
## 0) load data
BTC <- cryptoQuotes::get_quote(
	ticker = "BTCUSDC",
	futures = FALSE,
	interval = "1d",
	from = as.Date("2024-01-01"),
	to = as.Date("2024-12-31")
)

## 1) convert to matrix
BTC <- as.data.frame(
	BTC
)

## 2) store data
usethis::use_data(
	BTC,
	overwrite = TRUE
)
