## script: Generate Volatility Indicator for R
source("tools/gen_code/metadata_volatility_indicator.R")

for (x in metadata) {
	generate_R(x)
}
