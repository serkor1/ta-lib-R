## script: utilities
assert <- function(x, ...) {
  ## Assert truthfulness
  ## of x
  condition <- x
  if (!condition) {
    if (...length() == 0) {
      stop("Assertion failed", call. = FALSE)
    } else {
      stop(..., call. = FALSE)
    }
  }

  return(
    invisible(TRUE)
  )
}

flatten <- function(x) {
  if (!inherits(x, "list")) {
    list(x)
  } else {
    unlist(c(lapply(x, flatten)), recursive = FALSE)
  }
}

## extract open, high, low, close
## and volume by position
##
## offset if idx is present
##
## NOTE: Offset is like scratching your
##       left ear with your right arm
##       only added for backwards compatibility
##       - should remove it.
.open <- function(x, offset = FALSE) {
  x[, 1L + as.integer(offset)]
}
.high <- function(x, offset = FALSE) {
  x[, 2L + as.integer(offset)]
}
.low <- function(x), offset = FALSE {
  x[, 3L + as.integer(offset)]
}
.close <- function(x, offset = FALSE) {
  x[, 4L + as.integer(offset)]
}
.volume <- function(x, offset = FALSE) {
  x[, 5L + as.integer(offset)]
}

## map MAs
map_maType_call <- function(call_expr) {
  args <- as.list(call_expr)[-1L]
  head_chr <- as.character(call_expr[[1L]])
  fun_name <- tail(head_chr, 1L)

  maType <- switch(
    fun_name,
    SMA = 0L,
    EMA = 1L,
    WMA = 2L,
    DEMA = 3L,
    TEMA = 4L,
    TRIMA = 5L,
    KAMA = 6L,
    MAMA = 7L,
    T3 = 8L,
    stop(sprintf("Unknown MA type: %s", fun_name))
  )

  n_val <- args[["n"]]

  list(
    n = as.integer(n_val),
    maType = maType
  )
}

is.number <- function(x) {
  is.numeric(x) || is.integer(x)
}

.unwrap_meta <- function(expr, env) {
  repeat {
    if (!is.call(expr)) {
      break
    }
    head <- expr[[1L]]
    if (is.symbol(head) && as.character(head) %in% c("substitute", "quote")) {
      expr <- eval(expr, envir = env, enclos = env)
    } else {
      break
    }
  }
  expr
}

.is_ma_spec <- function(expr, env) {
  expr1 <- .unwrap_meta(expr, env)
  if (is.call(expr1)) {
    return(TRUE)
  }
  if (is.symbol(expr1)) {
    v <- try(
      get(as.character(expr1), envir = env, inherits = TRUE),
      silent = TRUE
    )
    return(!inherits(v, "try-error") && is.language(v))
  }
  FALSE
}

# Normalize one MA argument to a CALL, without forcing promises.
.normalize_ma_arg_expr <- function(expr, env) {
  expr1 <- .unwrap_meta(expr, env)
  if (is.call(expr1)) {
    return(expr1)
  }
  if (is.symbol(expr1)) {
    v <- get(as.character(expr1), envir = env, inherits = TRUE)
    if (is.language(v)) return(v)
  }
  stop("Expected an MA spec like EMA(n = 12).", call. = FALSE)
}

# Safe integer eval for the numeric path (after unwrapping).
.eval_int <- function(expr, env) {
  expr1 <- .unwrap_meta(expr, env)
  v <- eval(expr1, envir = env, enclos = env)
  if (!is.number(v) || length(v) != 1L || !is.finite(v)) {
    stop("fast/slow/signal must be finite numeric scalars.", call. = FALSE)
  }
  as.integer(v)
}


reclass <- function(x, ...) {
  class(x) <- c(class(x), ...)
}


## series
.univariate_series <- function(x) {
  as.double(
    x[, 1L]
  )
}
