## script: Generate Volume Indicator for R
source("tools/gen_code/metadata_volume_indicator.R")

for (x in metadata) {
	generate_R(x)
}
