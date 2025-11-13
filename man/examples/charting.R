## charting in {talib}
## using {plotly}
data(BTC, package = "talib")

## candlestick chart
## (default)
{
	talib::chart(
		BTC,
		type = "candlestick"
	)
}

## OHLC chart
{
	talib::chart(
		BTC,
		type = "ohlc"
	)
}

## reset the charting
## environment
talib::chart()
