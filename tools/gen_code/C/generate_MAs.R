## script: Generate Moving Averages for C
source("tools/gen_code/metadata_MAs.R")

for (x in metadata) {
	generate_C(x)
}
