## script: Generate Momentum Indicator for C
source("tools/gen_code/metadata_momentum_indicator.R")

for (x in metadata) {
	generate_C(x)
}
