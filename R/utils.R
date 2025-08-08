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

## map MAs
map_maType_call <- function(call_expr) {
  ## strip off the head and args
  args      <- as.list(call_expr)[-1L]
  head_chr  <- as.character(call_expr[[1L]])
  fun_name  <- tail(head_chr, 1L)

  maType <- switch(
    fun_name,
      SMA   = 0L,
      EMA   = 1L,
      WMA   = 2L,
      DEMA  = 3L,
      TEMA  = 4L,
      TRIMA = 5L,
      KAMA  = 6L,
      MAMA  = 7L,
      T3    = 8L,
    stop(sprintf("Unknown MA type: %s", fun_name))
  )

  n_val <- args[["n"]]

  list(
    n      = as.integer(n_val),
    maType = maType
  )
}

is.number <- function(x) {
  is.numeric(x) || is.integer(x)
}