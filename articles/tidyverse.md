# Tidyverse Workflows

[talib](https://serkor1.github.io/ta-lib-R/) indicators accept a
`data.frame` and return a `data.frame`—but the returned data frame
contains **only the indicator columns**, not the original data. This is
by design: it keeps the core API minimal and composable. In a tidyverse
pipeline, however, you usually want the indicator columns attached to
your existing data so you can keep piping.

This article builds a thin wrapper called `tidy_ta()` that bridges that
gap, then puts it to work in increasingly realistic scenarios.

``` r
library(talib)
#> Loading {talib} v0.9.0
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
library(tidyr)
```

## The gap

Piping into a [talib](https://serkor1.github.io/ta-lib-R/) indicator
works—`x` is the first argument:

``` r
BTC %>%
    RSI(n = 14) %>%
    tail()
#>                          RSI
#> 2024-12-26 01:00:00 46.48851
#> 2024-12-27 01:00:00 43.85488
#> 2024-12-28 01:00:00 45.93888
#> 2024-12-29 01:00:00 43.12301
#> 2024-12-30 01:00:00 41.47686
#> 2024-12-31 01:00:00 43.37358
```

The result is a one-column data frame with just the RSI values. The
original price data is gone. To keep both, you need to bind the
indicator output back to the input.

## Building `tidy_ta()`

The simplest version takes a data frame, passes it to an indicator, and
column-binds the result:

``` r
tidy_ta <- function(.data, .f, ...) {
    dplyr::bind_cols(.data, .f(.data, ...))
}
```

Three lines, and every indicator in
[talib](https://serkor1.github.io/ta-lib-R/) is now pipe-friendly:

``` r
BTC %>%
    tidy_ta(RSI, n = 14) %>%
    tail()
#>                         open     high      low    close   volume      RSI
#> 2024-12-26 01:00:00 99356.00 99879.98 95088.99 95676.01 2872.119 46.48851
#> 2024-12-27 01:00:00 95676.00 97388.00 93320.54 94167.77 3483.965 43.85488
#> 2024-12-28 01:00:00 94167.78 95563.86 94000.00 95120.76 1333.381 45.93888
#> 2024-12-29 01:00:00 95124.01 95170.03 92831.78 93564.00 2131.462 43.12301
#> 2024-12-30 01:00:00 93564.00 94915.26 91310.00 92628.01 4069.841 41.47686
#> 2024-12-31 01:00:00 92624.41 96132.00 91884.18 93390.63 2960.960 43.37358
```

Multi-column indicators work the same way—Bollinger Bands returns three
columns, and all three get bound:

``` r
BTC %>%
    tidy_ta(bollinger_bands) %>%
    tail()
#>                         open     high      low    close   volume UpperBand
#> 2024-12-26 01:00:00 99356.00 99879.98 95088.99 95676.01 2872.119 100487.38
#> 2024-12-27 01:00:00 95676.00 97388.00 93320.54 94167.77 3483.965 100670.65
#> 2024-12-28 01:00:00 94167.78 95563.86 94000.00 95120.76 1333.381 100632.13
#> 2024-12-29 01:00:00 95124.01 95170.03 92831.78 93564.00 2131.462  99628.77
#> 2024-12-30 01:00:00 93564.00 94915.26 91310.00 92628.01 4069.841  96403.53
#> 2024-12-31 01:00:00 92624.41 96132.00 91884.18 93390.63 2960.960  95441.13
#>                     MiddleBand LowerBand
#> 2024-12-26 01:00:00   96698.61  92909.83
#> 2024-12-27 01:00:00   96512.96  92355.27
#> 2024-12-28 01:00:00   96581.91  92531.69
#> 2024-12-29 01:00:00   95576.60  91524.43
#> 2024-12-30 01:00:00   94231.31  92059.09
#> 2024-12-31 01:00:00   93774.23  92107.34
```

Chaining multiple indicators composes naturally:

``` r
BTC %>%
    tidy_ta(RSI, n = 14) %>%
    tidy_ta(bollinger_bands) %>%
    tidy_ta(MACD) %>%
    tail()
#>                         open     high      low    close   volume      RSI
#> 2024-12-26 01:00:00 99356.00 99879.98 95088.99 95676.01 2872.119 46.48851
#> 2024-12-27 01:00:00 95676.00 97388.00 93320.54 94167.77 3483.965 43.85488
#> 2024-12-28 01:00:00 94167.78 95563.86 94000.00 95120.76 1333.381 45.93888
#> 2024-12-29 01:00:00 95124.01 95170.03 92831.78 93564.00 2131.462 43.12301
#> 2024-12-30 01:00:00 93564.00 94915.26 91310.00 92628.01 4069.841 41.47686
#> 2024-12-31 01:00:00 92624.41 96132.00 91884.18 93390.63 2960.960 43.37358
#>                     UpperBand MiddleBand LowerBand       MACD MACDSignal
#> 2024-12-26 01:00:00 100487.38   96698.61  92909.83  608.68287  1590.9032
#> 2024-12-27 01:00:00 100670.65   96512.96  92355.27  243.07106  1321.3368
#> 2024-12-28 01:00:00 100632.13   96581.91  92531.69   29.87501  1063.0444
#> 2024-12-29 01:00:00  99628.77   95576.60  91524.43 -261.68536   798.0985
#> 2024-12-30 01:00:00  96403.53   94231.31  92059.09 -561.79956   526.1189
#> 2024-12-31 01:00:00  95441.13   93774.23  92107.34 -729.69370   274.9564
#>                       MACDHist
#> 2024-12-26 01:00:00  -982.2204
#> 2024-12-27 01:00:00 -1078.2657
#> 2024-12-28 01:00:00 -1033.1694
#> 2024-12-29 01:00:00 -1059.7838
#> 2024-12-30 01:00:00 -1087.9184
#> 2024-12-31 01:00:00 -1004.6501
```

### Handling column-name collisions

If you add two SMAs with different periods, both return a column named
`SMA` and
[`bind_cols()`](https://dplyr.tidyverse.org/reference/bind_cols.html)
disambiguates with ugly suffixes like `SMA...6`. A `.suffix` parameter
fixes this:

``` r
tidy_ta <- function(.data, .f, ..., .suffix = NULL) {
    result <- .f(.data, ...)

    if (!is.null(.suffix)) {
        colnames(result) <- paste(colnames(result), .suffix, sep = "_")
    }

    dplyr::bind_cols(.data, result)
}
```

Now each indicator gets a clear name:

``` r
BTC %>%
    tidy_ta(SMA, n = 10, .suffix = "10") %>%
    tidy_ta(SMA, n = 20, .suffix = "20") %>%
    tail()
#>                         open     high      low    close   volume   SMA_10
#> 2024-12-26 01:00:00 99356.00 99879.98 95088.99 95676.01 2872.119 98217.88
#> 2024-12-27 01:00:00 95676.00 97388.00 93320.54 94167.77 3483.965 97020.16
#> 2024-12-28 01:00:00 94167.78 95563.86 94000.00 95120.76 1333.381 96516.01
#> 2024-12-29 01:00:00 95124.01 95170.03 92831.78 93564.00 2131.462 96134.41
#> 2024-12-30 01:00:00 93564.00 94915.26 91310.00 92628.01 4069.841 95620.42
#> 2024-12-31 01:00:00 92624.41 96132.00 91884.18 93390.63 2960.960 95236.42
#>                       SMA_20
#> 2024-12-26 01:00:00 99594.80
#> 2024-12-27 01:00:00 99305.69
#> 2024-12-28 01:00:00 99002.74
#> 2024-12-29 01:00:00 98814.94
#> 2024-12-30 01:00:00 98613.30
#> 2024-12-31 01:00:00 98223.05
```

The `cols` argument is forwarded through `...`, so column remapping
still works:

``` r
BTC %>%
    tidy_ta(RSI, cols = ~high, n = 14) %>%
    tail()
#>                         open     high      low    close   volume      RSI
#> 2024-12-26 01:00:00 99356.00 99879.98 95088.99 95676.01 2872.119 50.88773
#> 2024-12-27 01:00:00 95676.00 97388.00 93320.54 94167.77 3483.965 45.83913
#> 2024-12-28 01:00:00 94167.78 95563.86 94000.00 95120.76 1333.381 42.51414
#> 2024-12-29 01:00:00 95124.01 95170.03 92831.78 93564.00 2131.462 41.80903
#> 2024-12-30 01:00:00 93564.00 94915.26 91310.00 92628.01 4069.841 41.33147
#> 2024-12-31 01:00:00 92624.41 96132.00 91884.18 93390.63 2960.960 44.58689
```

This is the complete wrapper. The rest of the article uses it as-is.

## Grouped operations across assets

A common task is computing the same indicator across multiple tickers.
Stack the data,
[`nest()`](https://tidyr.tidyverse.org/reference/nest.html) by ticker,
apply `tidy_ta()` inside each group, and
[`unnest()`](https://tidyr.tidyverse.org/reference/unnest.html):

``` r
assets <- bind_rows(
    BTC  %>% as_tibble(rownames = "date") %>% mutate(ticker = "BTC"),
    SPY  %>% as_tibble(rownames = "date") %>% mutate(ticker = "SPY"),
    NVDA %>% as_tibble(rownames = "date") %>% mutate(ticker = "NVDA")
)

assets %>%
    nest(.by = ticker) %>%
    mutate(data = lapply(data, tidy_ta, RSI, n = 14)) %>%
    unnest(data) %>%
    select(ticker, date, close, RSI) %>%
    filter(!is.na(RSI)) %>%
    slice_tail(n = 3, by = ticker)
#> # A tibble: 9 × 4
#>   ticker date                  close   RSI
#>   <chr>  <chr>                 <dbl> <dbl>
#> 1 BTC    2024-12-29 01:00:00 93564    43.1
#> 2 BTC    2024-12-30 01:00:00 92628.   41.5
#> 3 BTC    2024-12-31 01:00:00 93391.   43.4
#> 4 SPY    499                   601.   54.6
#> 5 SPY    500                   595.   47.8
#> 6 SPY    501                   588.   41.9
#> 7 NVDA   499                    49.4  57.8
#> 8 NVDA   500                    49.5  58.3
#> 9 NVDA   501                    49.5  58.3
```

Because `tidy_ta()` returns the full enriched data frame,
[`unnest()`](https://tidyr.tidyverse.org/reference/unnest.html) restores
everything in one step. This scales to multiple indicators by chaining
inside the [`lapply()`](https://rdrr.io/r/base/lapply.html):

``` r
assets %>%
    nest(.by = ticker) %>%
    mutate(data = lapply(data, function(d) {
        d %>%
            tidy_ta(RSI, n = 14) %>%
            tidy_ta(bollinger_bands)
    })) %>%
    unnest(data) %>%
    select(ticker, date, close, RSI, UpperBand, MiddleBand, LowerBand) %>%
    filter(!is.na(RSI)) %>%
    slice_tail(n = 3, by = ticker)
#> # A tibble: 9 × 7
#>   ticker date                  close   RSI UpperBand MiddleBand LowerBand
#>   <chr>  <chr>                 <dbl> <dbl>     <dbl>      <dbl>     <dbl>
#> 1 BTC    2024-12-29 01:00:00 93564    43.1   99629.     95577.    91524. 
#> 2 BTC    2024-12-30 01:00:00 92628.   41.5   96404.     94231.    92059. 
#> 3 BTC    2024-12-31 01:00:00 93391.   43.4   95441.     93774.    92107. 
#> 4 SPY    499                   601.   54.6     607.       595.      583. 
#> 5 SPY    500                   595.   47.8     605.       597.      589. 
#> 6 SPY    501                   588.   41.9     606.       596.      586. 
#> 7 NVDA   499                    49.4  57.8      49.8       48.9      48.0
#> 8 NVDA   500                    49.5  58.3      49.7       49.2      48.7
#> 9 NVDA   501                    49.5  58.3      49.8       49.3      48.8
```

## Putting it all together

A complete pipeline: enrich a multi-asset dataset, flag RSI signals, and
find the most recent event per asset.

``` r
assets %>%
    nest(.by = ticker) %>%
    mutate(data = lapply(data, tidy_ta, RSI, n = 14)) %>%
    unnest(data) %>%
    filter(!is.na(RSI)) %>%
    mutate(
        signal = case_when(
            RSI > 70 ~ "overbought",
            RSI < 30 ~ "oversold"
        )
    ) %>%
    filter(!is.na(signal)) %>%
    slice_tail(n = 1, by = c(ticker, signal)) %>%
    select(ticker, date, close, RSI, signal) %>%
    arrange(ticker, signal)
#> # A tibble: 6 × 5
#>   ticker date                  close   RSI signal    
#>   <chr>  <chr>                 <dbl> <dbl> <chr>     
#> 1 BTC    2024-11-24 01:00:00 98016.   78.2 overbought
#> 2 BTC    2024-08-05 02:00:00 54045.   26.7 oversold  
#> 3 NVDA   474                    50.4  70.0 overbought
#> 4 NVDA   184                    12.2  28.9 oversold  
#> 5 SPY    484                   608.   70.7 overbought
#> 6 SPY    207                   411.   29.1 oversold
```

## Summary

The entire wrapper is six lines:

``` r
tidy_ta <- function(.data, .f, ..., .suffix = NULL) {
    result <- .f(.data, ...)
    if (!is.null(.suffix)) {
        colnames(result) <- paste(colnames(result), .suffix, sep = "_")
    }
    dplyr::bind_cols(.data, result)
}
```

It works because [talib](https://serkor1.github.io/ta-lib-R/) indicators
already follow the key convention: data frame in, data frame out, with
row counts and row names preserved. `tidy_ta()` just bridges the last
mile—binding the result back to the input so the pipeline keeps flowing.

The pattern is not specific to
[talib](https://serkor1.github.io/ta-lib-R/). Any function that takes a
data frame and returns a same-length data frame can be wrapped the same
way.
