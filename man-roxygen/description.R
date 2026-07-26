#' @description
#' `<%= tolower(.fun) %>()` is a generic S3 function that preserves
#' the input [class]: [data.frame] in, [data.frame] out; [matrix] in,
#' [matrix] out.
#'
#' 
<% if (any(grepl(pattern = "cols", x = names(formals(.fun))))) { %>

<% n_vars <- length(all.vars(as.formula(.formula))) %>
<% if (n_vars == 1) { %>
#' `<%= tolower(.fun) %>()` also accepts a [double] vector, in which case the indicator is calculated directly without column selection. When the result has a single column it is simplified to a [double] vector; otherwise the full `n` by `k` [matrix] is returned.
#' 
<% } %>
#'
#' ## Handling of `NA` values
#'
#' Every indicator always emits **leading `NA`s** for the initial
#' lookback period - positions where there is not yet enough data to
#' produce a result. This is separate from how `NA`s already present
#' in the input are handled, which is controlled by the `na.bridge`
#' argument:
#'
#' \describe{
#'  \item{`na.bridge = FALSE` (default)}{The input is passed to the
#'    underlying TA-Lib C routine as-is. Because most indicators smooth
#'    across time (EMA, RSI, MACD, Bollinger Bands, ...), a single
#'    `NA` in the input typically propagates forward and **poisons
#'    every subsequent value** - it is common for one missing
#'    observation to produce an output that is entirely `NA` from that
#'    position onward. This mode is the right choice when you want to
#'    *see* the missing data in the output rather than silently
#'    compute around it.}
#'  \item{`na.bridge = TRUE`}{`NA` rows are stripped from the input
#'    before the C routine runs; the indicator is computed on the
#'    resulting dense series; results are then re-expanded to the
#'    original length with `NA` inserted at every position the input
#'    had `NA`. Output length always matches input length, so the
#'    result can be joined back to the source `data.frame` by row.
#'
#'    **Consequence to understand before enabling:** bridging causes
#'    the indicator to treat non-consecutive observations as
#'    consecutive. A 14-period RSI with `na.bridge = TRUE` over a
#'    series containing a month-long gap will compute using 14
#'    observations that span several real-world months as if they were
#'    14 adjacent trading days. For sparse missing values (e.g. a
#'    single missing tick) this is harmless; for clustered gaps (e.g.
#'    a delisted period, a weekend encoded as `NA`) the output is
#'    correctly aligned *by position* but economically meaningless
#'    across the gap. Inspect gap structure with `which(is.na(x))`
#'    before enabling on low-quality time series.}
#' }
#'
#' 
#' @param x An OHLC-V series coercible to [data.frame].
<% if (n_vars == 1) { %>
#' Alternatively, `x` may also be supplied as a [double] vector.
<% } %>
#'
#' @param cols ([formula]). An optional `<%= length(all.vars(as.formula(.formula))) %>`-variable [formula] selecting columns from `x` via [model.frame].
#'  Defaults to `<%= deparse(as.formula(.formula)) %>`.
#'
<% } %>
#'
<% fun_args <- names(formals(.fun)) %>
<% if ("timePeriod" %in% fun_args) { %>
#' @param timePeriod ([integer]). Lookback period (window size). A positive [integer]
#'   of [length] 1.
<% } %>
<% if ("penetration" %in% fun_args) { %>
#' @param penetration ([double]). Penetration threshold for candlestick pattern
#'   recognition, expressed as a fraction of the candle body. A [double] of
#'   [length] 1.
<% } %>
<% if ("na.bridge" %in% fun_args) { %>
#' @param na.bridge ([logical]). A [logical] of [length] 1. [FALSE] by
#'   default. When [FALSE], input `NA`s propagate through the TA-Lib C
#'   routine (most indicators will fill the remaining output with
#'   `NA`). When [TRUE], input `NA` rows are stripped before
#'   computation and re-inserted at the original positions in the
#'   output, causing the indicator to treat non-consecutive non-`NA`
#'   observations as if they were adjacent — see the **Handling of
#'   `NA` values** section above for the consequences.
<% } %>
<% if ("..." %in% fun_args) { %>
#' @param ... Additional parameters passed into [model.frame].
<% } %>
#'
#' @author <%= .author %>
#'
#' @concept finance
#' @concept technical analysis
#' @concept trading
#' @concept algorithmic trading
#'
<% if (grepl(pattern = "Price Transform", x = .family)) { %>
#' @examples
#' ## load Bitcoin (BTC)
#' ## series
#' data(BTC, package = "talib")
#'
#' ## calculate the indicator
#' ## for Bitcoin (BTC)
#' output <- talib::<%= .fun %>(BTC)
#'
#' ## display the results
#' utils::tail(output)

<% } else { %>
#' @examples
#' ## load Bitcoin (BTC)
#' ## series
#' data(BTC, package = "talib")
#'
#' ## calculate the indicator
#' ## for Bitcoin (BTC)
#' output <- talib::<%= .fun %>(BTC)
#'
#' ## display the results
#' utils::tail(output)
#'
#' ## visualize the indicator
#' ## with talib::chart()
#' ##
#' ## see ?talib::chart or ?talib::indicator
#' ## for more details
#' {
#'  ## chart OHLC-V
#'  ## series with talib::chart()
#'  talib::chart(BTC)
#'
#'  ## chart indicator
#'  ## with default values
#'  talib::indicator(
#'      talib::<%= .fun %>
#'  )
#' }

<% } %>
