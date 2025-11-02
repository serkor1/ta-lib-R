## script: Generate Volume Indicator for C
source("tools/gen_code/metadata_volume_indicator.R")

for (x in metadata) {
	generate_C(x)
}
