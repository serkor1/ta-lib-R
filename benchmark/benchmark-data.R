## script: benchmark-data
## objective:
## 		This script can be called as
##      make bench-data n=1e3 to generate
##      a <data.frame>- and <matrix>-object
##		used for benchmarking
##
## 1) number of observations
n <- commandArgs(
	trailingOnly = TRUE
)

## 2) construct <data.frame>
##    as OHLC
set.seed(1903)
DT <- data.frame(
	open = runif(
		n = n,
		min = 100,
		max = 1000
	)
)

## 2.1)
DT$high <- DT$open + 20
DT$close <- DT$open - 10
DT$low <- DT$open - 20

## 3) stroe data
##
## 3.1) <data.frame>
saveRDS(
	DT,
	"benchmark/dataframe.rds"
)

## 3.2) <matrix>
saveRDS(
	as.matrix(DT),
	"benchmark/matrix.rds"
)
