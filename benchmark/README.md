
# Benchmarks

The benchmarks are run on the `bollinger_bands()` function, with three
different specifications:

1.  *baseline:* This specification calls the C routine directly, without
    any calls to R functions.
2.  *data.frame:* This specification is the S3 `<data.frame>` dispatch.
3.  *matrix:* This specification is the S3 `<matrix>` dispatch.

All benchmarks uses a 200000 row OHLC `<data.frame>`

## Benchmark results

    #> # A data frame: 3 × 6
    #>   expression      min   median `itr/sec` mem_alloc `gc/sec`
    #>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
    #> 1 baseline    922.8µs    1.7ms      707.    4.58MB     101.
    #> 2 data.frame   1.26ms   1.32ms      662.    9.17MB     420.
    #> 3 matrix        1.8ms   1.87ms      485.   13.74MB     725.
