## script: Generate Moving Averages for R
source("tools/gen_code/metadata_MAs.R")

for (x in metadata) {
	generate_R(x)
}
