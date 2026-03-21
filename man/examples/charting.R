## charting OHLC data with {talib}
data(BTC, package = "talib")

## candlestick chart (default)
talib::chart(BTC)

## OHLC bar chart
talib::chart(BTC, type = "ohlc")

## chart with a custom title
talib::chart(BTC, title = "Bitcoin / USD")

## reset the charting environment
talib::chart()
