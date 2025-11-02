## script: Generate Volatility Indicator for C
source("tools/gen_code/metadata_volatility_indicator.R")

for (x in metadata) {
	generate_C(x)
}
