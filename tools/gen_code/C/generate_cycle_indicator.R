## script: Generate Candlestick for C
source("tools/gen_code/metadata_cycle_indicator.R")

for (x in metadata) {
	generate_C(x)
}
