## script: Generate Candlestick for R
source("tools/gen_code/metadata_candlestick_pattern.R")

for (x in metadata) {
	generate_R(x)
}
