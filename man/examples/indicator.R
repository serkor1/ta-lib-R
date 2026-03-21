## indicator charts with {talib}
data(BTC, package = "talib")

## standalone indicator chart
## (no prior chart() call needed)
talib::indicator(
  talib::RSI,
  data = BTC
)

## attach an indicator to a price chart
talib::chart(BTC)
talib::indicator(talib::RSI, n = 14)

## multiple indicators on the same panel
talib::chart(BTC)
talib::indicator(
  talib::RSI(n = 10),
  talib::RSI(n = 14),
  talib::RSI(n = 21)
)

## reset chart state
talib::chart()
