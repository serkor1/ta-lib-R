## script: Generate Candlestick for R
source("tools/gen_code/metadata_cycle_indicator.R")

for (x in metadata) {
	generate_R(x)
}
