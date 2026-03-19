# Cosmos (ATOM)

USDC denominated Cosmos (ATOM) in daily intervals between 2022-01-01 and
2022-12-31.

## Usage

``` r
ATOM
```

## Format

A [data.frame](https://rdrr.io/r/base/data.frame.html) with 366 rows and
5 columns.

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
[cryptoQuotes](https://cran.r-project.org/web//packages/cryptoQuotes/index.html)

## Examples

``` r
## Load the dataset
data(ATOM, package = "talib")
```
