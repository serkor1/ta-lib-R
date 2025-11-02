## script: Generate Candlestick for C
source("tools/gen_code/metadata_candlestick_pattern.R")

for (x in metadata) {
	generate_C(x)
}
