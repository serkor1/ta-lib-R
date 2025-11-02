## script: Generate Overlap Study for R
source("tools/gen_code/metadata_overlapstudy.R")

for (x in metadata) {
	generate_R(x)
}
