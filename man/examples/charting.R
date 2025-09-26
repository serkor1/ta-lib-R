## charting in {talib}
## using {plotly}
x <- talib::BTC

## candlestick chart
## of BTC
talib::chart(x)

## adding indicators
## via indicator()
{
	## simple moving
	## averages
	talib::indicator(
		FUN = talib::SMA,
		n = 7
	)
	talib::indicator(
		FUN = talib::SMA,
		n = 14
	)
	talib::indicator(
		FUN = talib::SMA,
		n = 21
	)

	## MACD
	talib::indicator(
		FUN = talib::MACD
	)

	## OBV
	talib::indicator(
		FUN = talib::OBV
	)
}

## chart indicators
## without candlesticks
## by resetting the previous
## chart
talib::chart()

## chart indicator
talib::indicator(
	FUN = stochastic,
	data = x
)
