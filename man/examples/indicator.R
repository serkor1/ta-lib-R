## charting in {talib}
## using {plotly}
data(BTC, package = "talib")

## chart Relative Strength Index
## with default values
{
	talib::indicator(
		talib::RSI,
		data = BTC
	)
}

## chart Relative Strength Index
## with different values for 'n'
{
	talib::indicator(
		talib::RSI,
		data = BTC,
		n = 20
	)
}
