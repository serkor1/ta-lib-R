## script: utilities
assert <- function(exprs) {
    eval.parent(
        substitute(stopifnot(exprs = exprs))
        )
    }


## extractors
.open <- function(x) {x[,1]}
.high <- function(x) {x[,2]}
.low <- function(x) {x[,3]}
.close <- function(x) {x[,4]}
.volume <- function(x) {x[,5]}
