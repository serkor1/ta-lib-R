## script: Generate Momentum Indicator for R
source("tools/gen_code/metadata_momentum_indicator.R")

for (x in metadata) {
	generate_R(x)
}
