# SPDR S&P 500 ETF (SPY)

SPDR S&P 500 ETF (SPY) in daily intervals between 2023-01-01 and
2024-12-31.

## Usage

``` r
SPY
```

## Format

A [matrix](https://rdrr.io/r/base/matrix.html) with 501 rows and 5
columns.

- open:

  Candle opening price.

- high:

  Candle highest price.

- low:

  Candle lowest price.

- close:

  Candle closing price.

- volume:

  Candle volume.

## References

Loaded using
[quantmod](https://cran.r-project.org/web//packages//quantmod/index.html)

## Examples

``` r
## Load the dataset
data(SPY, package = "talib")
```
