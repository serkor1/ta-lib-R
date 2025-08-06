## script: BTC
## objective: Generate BTC
## data for the R package
## using {cryptoQuotes}
##
## 0) load data
BTC <- cryptoQuotes::get_quote(
    ticker = "BTCUSDC", 
    futures = FALSE, 
    interval = "15m"
)

## 1) convert to matrix
BTC <- matrix(
  data = BTC[,1:5],
  ncol = 5,
  dimnames = list(
    rownames(BTC),
    colnames(BTC)
  )
)

## 2) store data
usethis::use_data(
    BTC, 
    overwrite = TRUE
)


