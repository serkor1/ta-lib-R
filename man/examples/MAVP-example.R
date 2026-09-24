## load Bitcoin (BTC)
## series
data(BTC, package = "talib")

## define a random series
## of periods to evaluate
## each candle
periods <- runif(
	n = nrow(BTC),
	min = 5,
	max = 10
)

## calculate the indicator
## for Bitcoin (BTC)
utils::tail(
	talib::variable_moving_average_period(
		BTC,
		periods = periods
	)
)

## visualize the indicator
## with talib::chart()
##
## see ?talib::chart or ?talib::indicator
## for more details
{
	## chart OHLC-V
	## series with talib::chart()
	talib::chart(BTC)

	## chart indicator
	## with default values
	talib::indicator(
		talib::variable_moving_average_period,
		periods = periods
	)
}
