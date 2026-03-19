## script: ATOM
## objective: Generate ATOM
## data for the R package
## using {cryptoQuotes}
##
## 0) load data
ATOM <- cryptoQuotes::get_quote(
	ticker = "ATOMUSDC",
	futures = FALSE,
	interval = "1d",
	from = as.Date("2022-01-01"),
	to = as.Date("2022-12-31")
)

## 1) convert to matrix
ATOM <- as.data.frame(
	ATOM
)

## 1.1) sample rows for missing
##      data
set.seed(1903)
rows_with_na <- sample(
	1:nrow(ATOM),
	size = floor(nrow(ATOM) * 0.1)
)

## 1.2) replace with missing
##      values
ATOM[rows_with_na, ] <- NA


## 2) store data
usethis::use_data(
	ATOM,
	overwrite = TRUE
)
