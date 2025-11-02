## script: Generate Overlap Study for C
source("tools/gen_code/metadata_overlapstudy.R")

for (x in metadata) {
	generate_C(x)
}
