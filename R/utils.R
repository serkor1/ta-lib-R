## script: utilities
assert <- function(exprs) {
    eval.parent(
        substitute(stopifnot(exprs = exprs))
        )
    }
